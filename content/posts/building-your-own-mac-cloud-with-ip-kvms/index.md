+++
title = "Building your own Mac Cloud with IP KVMs"
date = 2026-09-13T12:00:00+02:00
draft = false
tags = ["macOS", "ip-kvm", "testing", "homelab"]
categories = ["macOS", "homelab"]
description = "A practical macOS test lab built from physical Macs, IP KVM devices, managed power, and an isolated network."
summary = "Why virtual machines and normal remote access are not enough for some low-level macOS tests, and what I learned from NanoKVM, JetKVM, GL.iNet Comet, and Comet PoE."
featuredImageAlt = "A small Mac test lab built around IP KVM devices"
resources = [
  { name = "featured-image", src = "featured-image.jpg" }
]
+++

## Introduction

In the [previous article](/posts/testing-low-level-macos-products/), I described the pros and cons of different approaches to testing macOS. Personally, I use real Macs most of the time, and virtual machines occasionally.

{{< image src="workspace-macs.jpg" alt="Three closed MacBooks arranged side by side on my desk" caption="My workspace, with three Macs waiting for their next job." >}}

I wanted a good solution for both testing and sharing devices, as well as for remote development. Travelling with several machines is inconvenient enough that I always had to choose: take my personal MacBook, or one of the work ones?

Read on to see what came of it.

## Using IP KVMs

I had considered IP KVM devices before, but older options were either too expensive or did not look trustworthy. I was also unsure about video latency.

But when JetKVM appeared on Kickstarter, that changed everything for me. I wanted to see if I could make this setup real, so I ordered a JetKVM, NanoKVM, and GL.iNet Comet.

Comet and JetKVM were preorders, so their first firmware versions were pretty rough. My guess is that they had been tested less with Macs, since their primary use case was access to Windows and Linux servers. So I put the project aside for quite a while and waited for the bugs to be fixed.

## Lab architecture

The basic design is simple:

1. Each Mac connects to the test network through Ethernet or Wi-Fi.
2. An IP KVM connects to the Mac over HDMI and USB, and to the management network over Ethernet.
3. A Mac mini receives power through a controllable socket. A MacBook receives power through its charger or a powered USB-C hub.
4. The network controls both the Mac's access and the KVM's access.

This gave me control over the Mac's power and network, as well as the KVM's network. But I also wanted to control the power of every KVM separately. I considered four variants:

1. A separate smart socket and small power adapter for each KVM. This works, but it is inefficient and takes up too much space.

{{< image src="architecture-smart-sockets.png" alt="Mac lab layout with separate smart sockets controlling power to the Mac mini and its IP KVM" caption="Separate smart sockets for the Mac and KVM." class="theme-aware-diagram" >}}

2. One AC/DC power supply, managed relays, and USB power boards. This is compact, but requires custom hardware and wiring.

{{< image src="architecture-managed-relay.png" alt="Mac lab layout with a shared AC/DC adapter and managed relay controlling power to the IP KVM" caption="A shared power supply and managed relay." class="theme-aware-diagram" >}}

3. A PoE switch plus a PoE splitter that separates Ethernet and USB power near each KVM.

{{< image src="architecture-poe-splitter.png" alt="Mac lab layout using a managed PoE switch and a PoE splitter to provide data and USB power to an IP KVM" caption="A PoE switch and splitter." class="theme-aware-diagram" >}}

4. A KVM with native PoE connected directly to a managed PoE switch. This is now the best option: the switch can control both the KVM's network access and its power.

{{< image src="architecture-native-poe.png" alt="Mac lab layout with a native PoE IP KVM connected directly to a managed PoE switch" caption="A native PoE KVM connected directly to the switch." class="theme-aware-diagram" >}}

The third option was originally the easiest to scale. Once KVMs with native PoE appeared, the fourth option became simpler because it no longer required a separate splitter.

### The power-button problem

Cutting and restoring AC power is not enough for every operation. Apple silicon Macs require a long press of the power button to enter startup options, and Wake-on-LAN or USB wake is not always reliable.

For me, physically modifying devices doesn't seem like a big deal, so I planned to simply connect wires to the power-button contacts and route them outside the case. I considered this using my old 2014 Mac mini as an example, but I think it would work with MacBooks as well.

I did not modify the test laptops because this was still an experiment. That decision made the lab less convenient: when a laptop failed to start, I had to remove it from the shelf, open the lid, and press the button manually.

Although soldering directly to the contacts doesn't seem like a big problem, this approach doesn't make sense at scale. If you plan to connect many devices, it is probably better to use special remote buttons that can be attached to them.

## Choosing the Macs

I considered used Mac minis and used MacBooks. Used Macs are a good fit for this kind of setup.

### Mac mini

Advantages:

- usually cheaper;
- direct AC power, easy to switch with a smart socket or managed relay;
- easier access to the power button;
- simple physical integration into a shelf or rack.

For a fixed test lab, this is the simplest and most reliable option.

### MacBook

Advantages:

- built-in display, keyboard, trackpad, and battery;
- can be removed from the lab and tested locally immediately;
- units with damaged displays can be inexpensive, but they lose some of their advantages.

For this kind of use, a MacBook is basically a Mac mini with a built-in UPS.

Disadvantages:

- usually more expensive;
- USB-C charging needs separate control;
- physical power-button control is harder;
- opening the lid creates another active display and can change the test setup.

With the lid closed, the [microphone is disconnected in hardware](https://support.apple.com/en-gb/guide/security/secbbd20b00b/web). So even if the laptop is sitting in a room and someone has access to it, they cannot listen to what's happening around it. The camera is blocked by the lid anyway. This applies to all Apple silicon Mac laptops and Intel models with a T2 chip, but not to every old Intel MacBook.

For my tests, I bought several Intel MacBooks and used my old Mac mini. I could get the MacBooks very cheaply, and I also wanted the option to install Windows through Boot Camp. In my opinion, they were the last really good laptops for running Windows. For a permanent lab, though, I would still choose Mac minis because they are much easier to integrate and recover remotely.

## The IP KVM devices I tested

I tested:

- Sipeed NanoKVM;
- JetKVM;
- GL.iNet Comet (GL-RM1);
- GL.iNet Comet PoE (GL-RM1PE).

I later added a Comet Q for a separate mobile-device use case; more on that below.

I did not buy a PiKVM. In my configuration it was more expensive and did not give me a clear advantage for this lab. Its main extra value was that the Raspberry Pi could later be reused for another project.

There are already enough detailed reviews of these KVMs online, so I won't go deeply into their specifications. I'll describe my impressions and the features I consider important for this particular use case. The videos are screen recordings of my tests, not controlled latency benchmarks. They show the end-to-end experience, including the network and browser used for each run.

I should also apologize: I'm writing this article quite a while after running the tests, so I may have forgotten or missed some details about each KVM.

### NanoKVM

NanoKVM was my least favorite device in the group. It didn't look great, had the highest latency in my tests, and for some reason I never got file sharing to work.

The hardware is still interesting for its size and price. Current [NanoKVM documentation](https://wiki.sipeed.com/hardware/en/kvm/NanoKVM/user_guide.html) describes virtual USB storage and ISO mounting, so the firmware is more capable than the early version I tested.

{{< image src="nanokvm-front.jpg" alt="NanoKVM connected to a Mac mini, showing its display and front controls" caption="NanoKVM connected to the test Mac." >}}

The USB connection can be used for both control and power. This has both advantages and disadvantages.
For me, it is more of a disadvantage because I want to control the KVM's power separately.

{{< image src="nanokvm-back.jpg" alt="Back of the NanoKVM enclosure and connected cables on a Mac mini" caption="The rear side of NanoKVM." >}}

{{< video src="nanokvm-test.mp4" caption="NanoKVM test." >}}

### JetKVM

JetKVM is a well-designed device. The case, display, and UI are clean, and local access is straightforward.

At the time of my first tests, it did not have the general file-sharing workflow I wanted. Current JetKVM firmware can [mount read-only virtual disks and installation images](https://jetkvm.com/docs/peripheral-devices/mount-drive) from internal storage, a URL, or the browser. That is useful for installation and recovery, but it is different from a read-write shared folder for moving arbitrary files in both directions.
Here too, power cannot be separated from the USB connection.

JetKVM's cloud uses Google Account authentication. There is also a [self-hosted option](https://jetkvm.com/docs/getting-started/faq), but I didn't test how it works.
Audio is not available when using the cloud connection.

And honestly, huge respect to the people behind this project. It looks really cool, and I think its success pushed other vendors to start developing their own small IP KVMs.

{{< image src="jetkvm-connected.jpg" alt="JetKVM connected by HDMI, USB, Ethernet, and power to a Mac mini" caption="JetKVM and its connections." >}}

{{< image src="jetkvm-display.jpg" alt="JetKVM front display showing its connection status beside a Mac mini" caption="The JetKVM status display." >}}

{{< video src="jetkvm-local.mp4" caption="JetKVM over the local network." >}}

{{< video src="jetkvm-cloud.mp4" caption="JetKVM through the hosted cloud path." >}}

### GL.iNet Comet

The original Comet isn't as nice-looking as JetKVM, but video latency and responsiveness were noticeably better in my tests, even at higher resolutions.

Its strongest feature for this use case is file transfer. Comet emulates a read-write USB drive, so files can move [from the controlling computer to the Mac and back](https://docs.gl-inet.com/kvm/en/tutorials/how_to_share_files_between_controlling_device_and_controlled_device/). Clipboard support also worked normally, as on other KVMs.

Because Comet switches to direct mode as soon as the browser can reach it locally, I connected the controlling Mac through mobile Internet to test their cloud relay. I really liked the result.

They also have their own app, which is pretty convenient. Unfortunately, it doesn't support their self-hosted cloud.

{{< image src="comet-rm1.jpg" alt="GL.iNet Comet GL-RM1 connected to a Mac mini" caption="GL.iNet Comet (GL-RM1)." >}}

{{< video src="comet-rm1-full-hd-relay.mp4" caption="Comet GL-RM1: Full HD through the hosted relay." >}}

{{< video src="comet-rm1-2k-relay.mp4" caption="Comet GL-RM1: 2K through the hosted relay." >}}

{{< video src="comet-rm1-full-hd-120hz-relay.mp4" caption="Comet GL-RM1: Full HD with a 120 Hz input through the hosted relay." >}}

### GL.iNet Comet PoE

Comet PoE covers more of the lab requirements because one managed PoE port provides both network and power. A switch can restart a KVM without affecting the connected Mac, disable its network port, or place it in a separate VLAN.

{{< image src="comet-rm1pe.jpg" alt="GL.iNet Comet PoE GL-RM1PE connected to a Mac mini" caption="GL.iNet Comet PoE (GL-RM1PE)." >}}

{{< video src="comet-rm1pe-2k-p2p.mp4" caption="Comet PoE: 2K over a peer-to-peer path." >}}

{{< video src="comet-rm1pe-2k-relay.mp4" caption="Comet PoE: 2K through the hosted relay." >}}

{{< video src="comet-rm1pe-full-hd-120hz-p2p.mp4" caption="Comet PoE: Full HD with a 120 Hz input over a peer-to-peer path." >}}

{{< video src="comet-rm1pe-2k-self-hosted.mp4" caption="Comet PoE: 2K through my self-hosted GLKVM server." >}}

I also tested GL.iNet's self-hosted cloud. Overall, it's done really well. The basic local-account flow still feels unfinished: an administrator can set a user's password, but the user cannot change it.

The important part for organizations is there, though: the [self-hosted GLKVM project](https://github.com/gl-inet/glkvm-cloud) supports LDAP and OIDC, along with user groups and device groups.

{{< image src="glkvm-self-hosted-cloud-redacted.png" alt="Self-hosted GLKVM device-management page showing one online Comet KVM with device identifiers redacted" caption="The device-management page in my self-hosted GLKVM instance. Device identifiers are redacted." >}}

{{< video src="comet-rm1pe-full-hd-120hz-relay.mp4" caption="Comet PoE: Full HD with a 120 Hz input through the hosted relay." >}}


### What is still missing—and what other drawbacks remain

#### USB passthrough

The main missing feature is general USB device passthrough. The tested KVMs emulate selected USB functions such as keyboard, mouse, storage, and sometimes audio. They do not forward an arbitrary local USB device to the remote Mac.

For example, I cannot attach a YubiKey to my laptop and make the remote Mac see that same physical key. GL.iNet has a public [feature request for YubiKey USB passthrough](https://forum.gl-inet.com/t/usb-passthrough-for-yubikey/62938), but this is a much harder problem than forwarding HID input.

#### Clipboard & file sharing

Clipboard transfer is one-way and text-only. It is not really clipboard synchronization: you paste text into a special field, and the KVM types it out one character at a time on the remote side. Naturally, keyboard layouts and special characters can cause problems.

To copy something in the other direction, you have to use file sharing. That is not a stream either. You mount a virtual “disk,” put the files on it, unmount it, and then download them—or do the same dance in reverse.

#### Remote debugging 

This is missing too. If you want to automate installing and launching an application, there is no straightforward way to do it. You need to invent an additional channel because you simply do not have direct access to the device's ports.

Virtual machines and ordinary remote devices are easier: you can connect over SSH and automate uploading an application, running commands, or even attaching a remote debugger.

#### Security perspective

At this point, I do not consider these devices vetted and trusted enough to deploy as-is. If you want to use them for production work, strict network isolation and tightly limited access are essential.

## My current setup

{{< carousel label="Photos of my current Mac lab" caption="My current setup from a few different, increasingly cable-heavy angles." >}}
  {{< carousel-image src="current-setup-detail.jpg" alt="Close view of two Macs and several KVM connections on the top shelf" caption="A closer look at the KVM connections." >}}
  {{< carousel-image src="current-setup-front.jpg" alt="Front view of the rack with two Macs, KVM devices, a switch, and Wi-Fi access points" caption="Macs and KVM hardware at the top; networking and power below." >}}
  {{< carousel-image src="current-setup-side.jpg" alt="Side view of the Mac lab showing stacked computers and connected KVM hardware" caption="The less photogenic side, where the cables explain everything." >}}
  {{< carousel-image src="current-setup-rack.jpg" alt="Front view of the compact equipment rack holding Macs, networking gear, and filament spools" caption="The rack that keeps most of the hardware in one place." >}}
    {{< carousel-image src="current-setup-in-use.jpg" alt="Three open MacBooks connected beside the Mac lab rack" caption="All three Macs connected for side-by-side testing." >}}
{{< /carousel >}}

Funny enough, during the actual testing I had three KVMs connected for quite a while, so I could test and compare them in parallel.
But my girlfriend commandeered one of the MacBooks, so the lab has since shrunk.

## The final setup I would build

For a permanent lab, I would use this layout:

1. Put all KVM devices in a dedicated management VLAN.
2. Connect them to a managed PoE switch with client or port isolation, so they cannot reach each other.
3. Block Internet access from the KVM VLAN by default.
4. Allow only the services that are required, such as a local NTP server.
5. Temporarily allow access to the vendor update server during planned firmware updates, or update devices locally.
6. Run a self-hosted management service with the organization's identity provider.
7. Allow access to that service only through a VPN.
8. Put the test Macs in separate VLANs when tests require different routing or firewall policies.

Each Mac also needs a remote power-button actuator, so it can be switched on or put into Recovery mode without anyone standing next to it.

That keeps power, KVM management, and the network seen by each test Mac separate. To me, this is a really interesting setup.

{{< image src="final-lab-architecture.png" alt="Final Mac lab architecture with multiple Mac minis, native PoE KVMs, managed power, a self-hosted KVM service, and VPN access" caption="The final setup I would build. Green lines carry power; black lines carry data." class="theme-aware-diagram" >}}


## Comet Q

{{< carousel label="Photos of the GL.iNet Comet Q" caption="The Comet Q, with and without its very orange protective case." >}}
  {{< carousel-image src="comet-q-front.jpg" alt="Front view of the black circular GL.iNet Comet Q" caption="The glossy front of the Comet Q." >}}
  {{< carousel-image src="comet-q-case.jpg" alt="GL.iNet Comet Q next to its orange protective case" caption="Comet Q and its removable protective case." >}}
    {{< carousel-image src="comet-q-connected.jpg" alt="GL.iNet Comet Q in an orange case with USB-C cables connected and its status screen on" caption="Comet Q powered up and connected." >}}

{{< /carousel >}}

I also got a [Comet Q](https://docs.gl-inet.com/kvm/en/user_guide/gl-rmq1/). It is designed for USB-C devices with DisplayPort Alt Mode, including phones, tablets, and laptops. It may be useful for mobile developers and security researchers, depending on how completely it can control the target screen and input path.

The device is genuinely cool and has a lot of promise for building something like an iPhone cloud. Still, I will treat that as a separate test. Mobile-device control has different constraints from a Mac lab, so it does not change the architecture described here.


## Conclusion

An IP KVM does not replace virtual machines. It fills the gap between a disposable VM and normal remote desktop access to a physical Mac.

For low-level macOS work, the useful part is not only the remote screen. It is the combination of pre-boot access, independent power control, physical networking, and real hardware. With a managed PoE switch and an isolated management network, a small group of used Mac minis can become a practical remote test lab without turning into a large infrastructure project.

## Did This Meet My Initial Requirements?

I think this was a genuinely interesting bit of research, but unfortunately the result still does not meet my requirements for remote work—mainly because of security. I like how it works, and although I analyzed the traffic from the GL.iNet devices and found nothing particularly suspicious, my inner security engineer will not let me use them in work projects.

I still use the setup for personal projects and some tests, and sometimes even share it with friends for their testing. I just did not integrate the idea into my day-to-day workflow.