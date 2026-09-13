+++
title = "Testing Low-Level macOS Products"
date = 2026-08-24T12:00:00+02:00
draft = false
tags = ["macos", "testing"]
categories = ["macos"]
description = "Why virtual machines and normal remote access are not enough for some low-level macOS tests."
summary = "Why virtual machines and normal remote access are not enough for some low-level macOS tests."
resources = [
  { name = "featured-image", src = "featured-image.png" }
]
+++

Most macOS application testing is done with virtual machines, physical Macs, or remote access to physical Macs. For one developer, this is often enough. For a larger team working on complex low-level software, each approach has its own pros and cons.

In this article, I compare these common approaches and describe the main nuances of using them for development and manual testing. Automated integration testing is outside the scope of this article.

I describe how I built a personal Mac cloud for testing in the [next article](/posts/using-ip-kvms-for-a-small-mac-cloud/).

## What I need to test

I develop low-level products for macOS, so verifying that a product works well across all supported macOS versions often requires testing on different devices. Most of my tests focus on system behavior across macOS versions and hardware configurations rather than on application UI alone.

Some bugs can be reproduced only on a specific Mac model, storage configuration, CPU architecture, or OS installation. Developers and QA need a practical way to access those machines.

I also sometimes reverse engineer software or test malware behavior. I prefer doing that on a separate physical machine rather than in a VM. Intel Macs are still useful here: for non-commercial research, [IDA Free](https://hex-rays.com/ida-free) provides an x86/x86-64 decompiler, but not an ARM decompiler.

These requirements led me to compare the practical trade-offs of virtual machines, local physical Macs, and remotely accessible Macs.

## Why I wasn't satisfied with the usual options

The use cases are very different, so unfortunately I couldn't organize them perfectly. As a result, some of the approaches and examples below overlap.

### Virtual machines

{{< image src="virtual-machines.png" alt="A pencil drawing of a MacBook running two virtual machines with an external SSD beside it" >}}

Virtual machines are still the best tool for many cases. They are easy to create, reset, and automate. The problem is that they do not reproduce every hardware and operating-system condition. There are also some nuances when testing products that require specific entitlements.

#### Apple Virtualization framework

Before Apple introduced its [Virtualization framework](https://developer.apple.com/documentation/virtualization) for macOS VMs on Apple silicon, virtual machines were probably the most versatile way to test macOS software. You could change the provisioning UUID, sign in with your Apple ID, and do many other things.

Apple's Virtualization framework made VMs very quick and easy to create. They were fast and generally worked well, but had many limitations compared with older Parallels Desktop VMs on Intel. [Here is Parallels' current list of limitations on ARM](https://kb.parallels.com/en/128867).

For my macOS VM use case, Parallels Desktop on Apple silicon does not currently offer enough extra value over free tools such as UTM and VirtualBuddy.

The main limitations for me were the inability to sign in with an Apple ID, the lack of native clipboard sharing, and the inability to set an arbitrary UUID or change many other parameters.

You could get clipboard sharing by connecting to the VM locally over VNC, but the other problems remained. Even with these limitations, VMs still covered most everyday use cases.

#### Host and guest version dependencies

The capabilities of macOS VMs built with Apple's Virtualization framework depend on the host and guest OS versions.

##### iCloud

macOS 15 Sequoia was an important change. Apple added [Apple Account and iCloud access in macOS VMs](https://developer.apple.com/documentation/virtualization/using-icloud-with-macos-virtual-machines), but only for VMs created on macOS 15 or later from a macOS 15 or later restore image. Upgrading an older VM to macOS 15 does not add iCloud support.

##### Clipboard sharing

The same applies to clipboard sharing. [UTM supports it for macOS guests](https://docs.getutm.app/guest-support/macos/#clipboard-sharing) when both the host and guest are running macOS 15 or later.

An interesting detail is that the [clipboard-sharing API](https://developer.apple.com/documentation/virtualization/clipboard-sharing) has been part of the Virtualization framework since macOS 13, but Apple's example showed it working with a [Linux guest](https://developer.apple.com/documentation/virtualization/running-gui-linux-in-a-virtual-machine-on-a-mac).

While writing this article and double-checking my claims, I discovered that [VirtualBuddy](https://github.com/insidegui/VirtualBuddy) seems to have supported clipboard sharing even before macOS 15. It simply used a different mechanism.

At first, I assumed that macOS 15 had added SPICE—or at least part of it—to the guest. In practice, UTM still installs `spice-vdagent` as part of its guest tools, while VirtualBuddy uses its own VirtualBuddyGuest helper.

##### VM identity

With UUIDs, it was the opposite. Before macOS 15, you could substitute a UUID, but not just any UUID—you had to take one from another virtual machine. The UUIDs of these VMs always started with the same prefix, and that prefix couldn't be replaced.

Starting with macOS 15, a new VM receives an identity derived from the host's Secure Enclave. Moving it to another Mac, or running cloned copies at the same time, can create a new identity and require Apple Account authentication again.

#### Provisioning UUID

Not being able to substitute a provisioning UUID is the main problem with VMs for me, because I mostly test products that require specific entitlements.

A development provisioning profile requires registered devices, and the Apple Developer Program permits [up to 100 registered Macs per membership year](https://developer.apple.com/help/account/devices/devices-overview/).

As I mentioned above, VMs created with versions earlier than macOS 15 could reuse a UUID from another VM. This meant that I only had to add one VM to my Apple Developer account.

You can still create a VM with macOS 14 and then upgrade it, preserving the older UUID behavior. The upgraded VM will not gain Apple Account or iCloud support.

Note: you can't sign in with your Apple ID in System Settings, but you can still sign in to your Apple Account in Xcode if you need to.

Quinn “The Eskimo!” provides [some useful history on this topic](https://developer.apple.com/forums/thread/787500?answerId=843094022#843094022).

#### SSD and disk behavior

Some storage work cannot be reproduced accurately with a virtual disk.

Examples include:

- performance tests for real file-system operations;
- performance comparisons involving virtual disks, where the host storage and virtualization layer introduce additional variables;
- bugs tied to a specific storage configuration, such as Fusion Drive.

VMs are useful for functional file-system tests and for comparing different software approaches under controlled conditions, but they are not a replacement for physical storage when the hardware is part of the problem.

#### The two-VM license limit

It would actually be great to buy a few powerful Macs, run many VMs with different macOS versions on them, and make all those VMs remotely accessible.

That setup could cover a lot of use cases. Unfortunately, Apple limits each host to two concurrent macOS VMs.

Apple's [macOS software license](https://www.apple.com/legal/sla/docs/macOSSequoia.pdf) permits up to two additional macOS copies or instances in virtual operating-system environments on each Apple-branded Mac you own or control.

There are [technical ways to get around this limit](https://khronokernel.com/macos/2023/08/08/AS-VM.html), but doing so would violate the license and make the setup harder to support.

#### Storage

VMs also consume a lot of disk space, so the built-in drive usually cannot hold a large collection of different environments. This is easy to address with an external SSD: the VMs can be stored and run directly from it.

#### Cases where VMs are better

Some tests are still easier in a VM. Authorization plug-ins are a good example: a broken login flow can be reset quickly from a snapshot. A physical machine becomes more valuable when the test also involves Active Directory, a specific network, real peripherals, or disk behavior.

VMs are also great for automated testing. You can deploy preconfigured machines automatically and run automated tests on them.

### The number of physical machines

{{< image src="multiple-devices.png" alt="A pencil drawing of three MacBooks running different operating system versions" >}}

Giving developers several physical Macs is a common approach, but it is not always the most efficient one. A developer can test on several devices in parallel or leave a long-running test on one machine while continuing to work on another.

However, giving every developer a complete set of supported devices rarely makes sense. A more practical compromise is to assign a few machines to each person and agree on which hardware and OS configurations each machine will maintain.

The main disadvantage is mobility. Carrying several Macs while travelling is inconvenient.

### Multiple macOS installations

{{< image src="multiple-installations.png" alt="A pencil drawing of a MacBook showing three startup volumes in the boot picker" >}}

A physical Mac can contain several macOS installations on separate APFS volumes. This works, but it also creates small maintenance problems. For example, Spotlight and Launch Services can discover applications on another mounted system volume, so a search may open an application from the wrong installation. You can reduce this by unmounting or excluding volumes, but the setup is no longer completely independent.

You can also install macOS on an external SSD and boot directly from it. I would use this only when the other options are unavailable.

### Remotely accessible Macs

{{< image src="vnc.png" alt="A pencil drawing of one laptop connected to three remote VNC sessions" >}}

Providing remote access to physical Macs requires several decisions:

1. Where will the devices be physically located?
2. Who can physically restart them or put them into Recovery Mode?
3. How will users connect: VPN and VNC, or a separate service such as TeamViewer, AnyDesk, or Splashtop?
4. How will access be restricted when some devices should be available only to specific users?

This kind of setup is not very common because it creates significant management overhead. With software-only remote access, you cannot interact with Recovery Mode. After some system updates, you may also need to sign in and complete the macOS setup flow before third-party remote-access services can start, making the machines harder to support.

In the deployments I have seen, each device was also connected to a KVM. These were traditional multiport KVMs that allowed only one connected machine to be controlled at a time. This was enough to complete a post-update setup flow and then switch back to VNC, but access to Recovery Mode could still be awkward.

In the [next article](/posts/using-ip-kvms-for-a-small-mac-cloud/), I explain how I addressed these limitations in my own setup.

#### VNC

I don't know about you, but VNC is also a problem for me. No matter how many times I've tried to use it, it has always worked much worse than RDP on Windows.

It is acceptable for some tests, but overall my experience with it hasn't been very good. Still, VNC has several useful features, including clipboard and file sharing.

#### Recovery, Safe Mode, and SIP

{{< image src="recovery-mode.png" alt="A pencil drawing of a MacBook showing first aid, security, and boot disk recovery options" >}}

Normal screen sharing stops being useful when macOS is not running or the Mac is frozen. Recovery Mode, Safe Mode, startup-disk selection, and some System Integrity Protection changes require interaction before normal remote-access software starts.

Apple silicon adds another requirement: to open startup options, you must [press and hold the physical power button](https://support.apple.com/en-us/102603). Wake-on-LAN or a virtual USB keyboard cannot replace that operation.

### Network testing

{{< image src="network-testing.png" alt="A pencil drawing of a MacBook connected through a router, switch, firewall, VPN, and cloud endpoint" >}}

Both VMs and remotely accessed Macs are poor fits for some kinds of network testing.

A remote Mac is especially risky here because a configuration change can make you lose access to the device. You are especially likely to lose access when testing Network Extensions such as VPN clients or firewalls.

More generally, even when I'm not testing Network Extensions, I often need to:

- switch between Wi-Fi and Ethernet;
- test captive or restricted networks;
- block selected destinations on an external firewall.

A VM sees virtual network devices rather than the physical Wi-Fi interface. Network Link Conditioner can simulate delay, packet loss, and limited bandwidth, but it does not reproduce every interface transition or external-network policy.

{{< image src="network-link-conditioner.png" alt="Network Link Conditioner settings showing separate bandwidth, packet-loss, and delay controls for uplink and downlink traffic" caption="Network Link Conditioner is useful for degraded-network simulation, but it cannot reproduce every physical interface transition." >}}

For firewall tests, I prefer putting a dedicated Mac on its own network. I can then change routing and filtering without affecting my primary machine.

#### VPN and routing from early boot

Sometimes a test Mac must reach a private resource, such as Active Directory, as early as possible during startup. I may also need to simulate a device operating inside a specific network with access to its resources.

A VPN inside the guest starts only after enough of the guest OS is running. A physical Mac on a dedicated network lets the router enforce the required route before the Mac finishes booting.

#### Testing changes that affect remote access

Sometimes I need to test how software interacts with remote-access tools on macOS: blocking them under specific conditions, configuring rules, or enabling and disabling access.

Even ordinary VPN, proxy, or firewall testing can accidentally block the connection to a remote Mac. Once that happens, physical access may be required to restore it.

### Sleep mode

{{< image src="sleep-mode.png" alt="A closed sleeping laptop dreaming about a capybara and laptop holding hands" >}}

Many problems in Endpoint Security clients, Network Extensions, and other low-level software are related to sleep and wake behavior. These may involve dark wake events, long sleep periods, and many other transitions.

A few examples:

1. WebSocket, TCP, or VPN sessions may be broken after wake because the network can become available later than the process resumes, while the peer may already have closed the session after a timeout.
2. Network Extensions can require additional handling for sleep-related bugs. WireGuard's history contains examples involving [route reconfiguration after wake](https://github.com/WireGuard/wireguard-apple/commit/c7b7b1247b27e08f26ec403f959748564b87b0cb) and [sleep and wake notifications in its packet-tunnel provider](https://github.com/WireGuard/wireguard-apple/blob/master/Sources/WireGuardNetworkExtension/PacketTunnelProvider.swift#L84).
3. Endpoint Security event-response handling can also encounter problems around sleep and wake transitions.

In practice, these scenarios are inconvenient to test in VMs or on machines that can be reached only through ordinary remote-access software.

## Comparison and conclusions

| Requirement | VMs | Local physical Macs | Remotely accessible Macs |
| --- | --- | --- | --- |
| Hardware and storage fidelity | Virtual hardware does not reproduce every device, SSD, or OS condition. | Can match the required model, storage, CPU architecture, and OS installation. | Provides the same physical-hardware fidelity as a local Mac. |
| Reset and repeatability | Easy to snapshot, clone, and reset. | Recovery takes more time and usually requires direct access. | Recovery takes more effort; managed power and a KVM can reduce the need for on-site help. |
| Scale | Multiple environments can share a host, but Apple permits only two concurrent macOS VMs per Apple-branded Mac. | Giving every developer a complete device set is impractical. | A shared lab makes a smaller device pool available to more people. |
| Mobility | Easy to carry on one host if storage capacity is sufficient. | Carrying several Macs while travelling is inconvenient. | Accessible from anywhere, subject to network availability and access controls. |
| Network testing | Uses virtual network devices and cannot reproduce every physical interface transition. | Supports real Wi-Fi, Ethernet, and isolated test networks. | Supports physical network testing, but a configuration mistake can cut off remote access. |
| Recovery, Safe Mode, and SIP | Cannot reproduce every physical boot and recovery workflow. | Full physical control is available. | Software-only access is limited; a KVM and remote power control cover more scenarios. |
| Sleep and wake testing | Does not fully reproduce a physical Mac's sleep behavior. | Practical, with direct access available if the machine does not wake correctly. | Possible, but failures can leave the machine unreachable without an independent control path. |
| Automation | Excellent for preconfigured environments and automated test runs. | Possible, but reinstallation and recovery are slower. | Useful for shared manual testing and some automation, with additional lab management. |

No single approach covers every low-level macOS testing scenario. VMs are the best option when speed, repeatability, snapshots, and automation matter most. Physical Macs are necessary when a test depends on real hardware, storage, networking, recovery, or sleep behavior. Keeping several machines locally provides direct control, but it does not scale well across a team or while travelling.

A shared remote lab makes physical Macs much more useful, but ordinary remote-access software introduces its own failure modes. The most practical setup is therefore a combination: VMs for fast and repeatable work, plus a smaller pool of physical Macs with an independent way to control their network, power, and pre-boot state.

The [next article](/posts/using-ip-kvms-for-a-small-mac-cloud/) describes the remote Mac lab I built around that idea.
