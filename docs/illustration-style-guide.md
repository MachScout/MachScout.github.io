# Illustration style guide

## Direction: Soft Technical Sketch

Use a controlled hand-drawn technical style for device illustrations, flowcharts,
and network diagrams. The result should feel like a carefully prepared engineering
notebook: approachable and tactile, but still precise enough to explain a system.

The source assets live in
`assets/images/diagram-kit/soft-technical-sketch/`. They are PNG files with
transparent backgrounds so the article controls the final canvas color.

## Visual language

- Draw outlines in dark graphite with small variations in pressure. Lines may feel
  handmade, but device geometry and connections must remain easy to read.
- Use light watercolor or marker washes inside objects. Leave generous unpainted
  space and avoid dense illustration backgrounds.
- Keep shadows faint, soft, and confined to the object. Never generate a paper
  rectangle, vignette, glow, or opaque background around an asset.
- Prefer front or subtle three-quarter views. Use the same viewing angle for
  devices that appear together.
- Simplify small hardware details, but keep ports, antennas, status lights, and
  cable paths technically plausible.
- Do not place text or labels inside generated raster assets. Add article-specific
  labels separately so they remain editable and accessible.

## Palette

| Role | Color |
| --- | --- |
| Graphite line | `#252A30` |
| Primary blue | `#3273DC` |
| PoE green | `#2F9E64` |
| AC orange | `#D97706` |
| DC violet | `#7C5CE7` |
| Silver and neutral surfaces | cool off-white and light gray |
| Secondary wash | pale sage green |
| Optional decision or warning wash | light warm ochre |

Blue is the main functional accent for screens and data paths. Green identifies
PoE or a positive status. Orange and violet are reserved for AC and DC power
connections. Ochre should be sparse and must not be confused with AC orange.

## Device rules

- **MacBook:** show it open, from the front at a slightly elevated angle. The
  complete screen, keyboard, and large trackpad must be visible. Always include
  the centered black display notch at the top of the screen.
- **MacBook, rear view:** show the open computer from behind in a subtle
  three-quarter view. Keep the silver lid, black hinge strip, thin base, and
  centered dark Apple logo visible. This logo is the one deliberate exception
  to the general no-logo rule because it identifies the otherwise featureless
  rear lid.
- **Mac mini:** use a compact rounded-square silver enclosure in a subtle
  three-quarter view. Show only ports that help identify the front face.
- **Router:** use a restrained professional enclosure, three slim antennas,
  recognizable Ethernet ports, ventilation, and a few small status lights.
- **Ethernet switch:** show a compact desktop enclosure with one clean row of
  recognizable RJ45 ports and no antennas.
- **KVM over IP:** use the compact JetKVM-inspired wedge enclosure, two visible
  top screws, side ventilation, and a curved front status display. Replace tiny
  interface copy with abstract lines and status dots so it remains legible at
  diagram scale without embedding fake text.
- **AC source:** use a recognizable European Schuko Type F outlet with a small
  orange sine-wave mark. Keep the outlet isolated, with no cable attached.
- **AC/DC power supply:** use a compact dark power brick. Its smooth AC lead is
  orange `#D97706` and ends in a Schuko plug; its smooth DC lead is violet
  `#7C5CE7` and ends in a device-appropriate connector such as USB-C.

Avoid logos other than the explicitly allowed rear-lid Apple mark, model names,
interface text, decorative cables, and photorealistic product-render lighting.

## Capybara character

The reusable capybara is derived from the site logo and acts as a small guide or
observer inside technical illustrations. Keep the character visually compatible
with the device set rather than rendering realistic fur.

- Preserve the warm chestnut-brown body, lighter tan muzzle and belly, compact
  rounded proportions, tiny dark eyes, broad blunt muzzle, and matte black
  deerstalker hat.
- Use broad watercolor or marker fills with only sparse pencil texture. Do not
  draw individual hair strands or dense fur detail.
- Keep the pose neutral and the silhouette readable at diagram scale. The hat is
  the primary identity marker and remains visible in every viewpoint.
- Do not include the logo's magnifying glass, green apple, insect, badge, or
  circular frame unless an article specifically needs one of those elements.
- Capybaras have no prominent visible tail; do not add a large tail in rear or
  side views.

The base transparent PNG viewpoints are:

- `capybara-front.png`
- `capybara-side.png` — right-facing profile
- `capybara-rear.png`

The reusable working scene is `capybara-working-at-macbook.png`: the capybara
sits behind a plain warm-wood desk in a subtle three-quarter view, with the open
rear-facing silver MacBook and its centered Apple logo visible. Keep this scene
free of decorative office props and cables. The chair must remain structurally
readable: include its backrest, seat edge, and at least two clearly visible legs
that are thinner than the desk legs.

Use `capybara-working-at-macbook-screen.png` when the display needs to be the
focus. It shows the same scene from behind the capybara's left shoulder, keeping
the complete notched screen, keyboard, and trackpad visible. The generic blue
macOS desktop has a menu bar and Dock but no readable interface text.

## macOS desktop inserts

Reusable desktop inserts are opaque `1600x1000` PNG files in a 16:10 aspect
ratio. They are designed to fit directly inside the open MacBook screen or a
separate remote-session frame.

- Preserve the recognizable composition and palette of the stock wallpaper,
  but redraw it with the same light watercolor and pencil texture as the device
  set.
- Include a slim translucent macOS menu bar at the top and a centered
  translucent Dock at the bottom.
- Keep Dock icons small and simplified. Do not add readable menu text, version
  labels, desktop files, a cursor, notifications, or open windows.
- Use a flat straight-on view with no bezel, perspective, external background,
  or rounded device frame.

The reusable series contains:

- `desktop-macos-monterey.png`
- `desktop-macos-ventura.png`
- `desktop-macos-sonoma.png`
- `desktop-macos-sequoia.png`
- `desktop-macos-tahoe.png`
- `desktop-macos-golden-gate.png`

## Diagram rules

- Use tidy orthogonal connection paths where possible.
- Keep arrowheads small, dark, and unambiguous.
- Use rounded rectangles for actions or components and diamonds for decisions.
- Leave node interiors empty in reusable assets; add labels during article
  composition.
- Do not rely on color alone. Each connection type also has a distinct line or
  connector treatment.
- Keep physical cables smooth and restrained. Do not draw a twisted, braided,
  doubled, or helical cable body.
- End a cable in open space near its component, with a small visible air gap.
  Connectors must not enter or overlap a rendered device port or chassis.
- Keep enough space between components for labels and for legibility on mobile.

## Connection language

| Connection | Color | Shape and endpoint treatment |
| --- | --- | --- |
| Ethernet | `#3273DC` | One smooth blue cable with a small RJ45 connector at each detached end. The connectors, not a twisted cable body, identify the link as twisted-pair Ethernet. |
| PoE | `#2F9E64` | The same smooth cable and detached RJ45 ends as Ethernet, plus one small lightning marker near the cable midpoint. |
| Wi-Fi | `#3273DC` | A dotted curved path with three short radio-wave arcs oriented between the devices; no cable or connector. |
| AC power | `#D97706` | A slightly relaxed or gently curved cable with a recognizable AC mains plug silhouette at its detached source end. |
| DC power | `#7C5CE7` | A smooth, straighter cable with a detached barrel, USB-C, or other device-appropriate low-voltage connector. |

All connection strokes use a thin graphite `#252A30` keyline so they remain
legible on both light and dark canvases. Use the semantic color consistently
across an article. Do not recolor a cable merely to separate nearby paths.

Ethernet and PoE use the same geometry because both run over twisted-pair cable.
PoE is distinguished redundantly by green and a lightning marker. Wi-Fi never
touches a device: both the dotted path and its radio-wave arcs remain separated
from the illustrated hardware.

## Reusable prompt template

```text
Use case: background-extraction
Asset type: reusable transparent PNG illustration for a technical blog diagram
Primary request: Draw one [SUBJECT] as a clean isolated asset.
Subject: [VIEWPOINT, REQUIRED PARTS, AND TECHNICALLY IMPORTANT DETAILS].
Style/medium: Soft Technical Sketch — controlled hand-drawn graphite ink
contours with slightly imperfect pressure, very light watercolor and marker
washes, professional engineering notebook aesthetic, not childish.
Color palette: graphite #252A30, cool off-white and gray, muted cornflower blue
#3273DC, with sparse pale sage status accents.
Materials/textures: delicate pencil shading and dry watercolor texture; crisp
readable silhouette; only a faint contact shadow confined to the object.
Composition/framing: centered isolated object, generous transparent padding,
no crop.
Background: genuinely transparent with a real alpha channel; no white or black
background, checkerboard, paper rectangle, vignette, or glow.
Constraints: no text, labels, letters, numbers, logos, watermark, decorative
objects, scenery, or photorealism.
```

Add subject-specific invariants at the end of the prompt. For a MacBook, repeat
that the centered top display notch, keyboard, and trackpad must be visible. For
network equipment, state the exact number and type of ports or antennas.

## Using an asset in an article

The existing Hugo image shortcode resolves page-bundle resources. Copy the chosen
library PNG into `content/posts/<post-name>/` before referencing it from an
article. Keep the library version unchanged so it remains a reusable source.

Always provide meaningful alt text unless the asset is purely decorative.
