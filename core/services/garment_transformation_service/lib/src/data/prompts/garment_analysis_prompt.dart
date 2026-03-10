
const String garmentAnalysisPromptThin = '''
Task: 
Generate a name and description of the attached image. 

Inputs: 
Image of a clothing garment

Output: 
Name is an accurate name representing the garment
Description is an accurate description of the color, material and type of clothing this is. 


Return in json format
{
  name: <NAME> as string
  description: <DESCRIPTION> as string
}
''';

const String garmentAnalysisPrompt = '''
Extract structured information about the garment visible in the image. 
Return the result strictly as JSON using the schema below. 
If a value cannot be determined, return null. 
Use concise values where possible.
---

GARMENT INFO EXTRACTION

product_description
Data type: string
Description: Short natural-language description of the garment similar to a product listing.
Examples:

* "Black oversized cotton hoodie with kangaroo pocket and ribbed cuffs"
* "Blue slim-fit denim jacket with metal buttons"

identify_materials
Data type: array<string>
Description: Materials visually inferred from the garment. List the primary fabrics present.
Examples:

* ["cotton"]
* ["denim", "cotton"]
* ["wool", "polyester blend"]

identify_brand
Data type: string or null
Description: Brand detected via logo, label, or recognizable design. If no brand is visible return null.
Examples:

* "Nike"
* "Levi's"
* null

color_palette
Data type: array<string>
Description: Dominant colors present in the garment. This may also be programmatically extracted from the image.
Examples:

* ["black"]
* ["blue", "white"]
* ["beige", "brown", "cream"]

garment_name
Data type: string
Description: Simple human-readable name for the garment.
Examples:

* "Oversized Hoodie"
* "Denim Jacket"
* "Athletic Tank Top"

---

GARMENT CATEGORY

garment_type
Data type: string
Description: High-level clothing category.
Examples: t-shirt, hoodie, jacket, coat, dress, skirt, trousers, shorts, jeans

sub_type
Data type: string
Description: More specific garment classification.
Examples: bomber jacket, pullover hoodie, polo shirt, denim jacket

gender_target
Data type: string
Description: Intended gender category.
Examples: menswear, womenswear, unisex

age_category
Data type: string
Description: Intended age group.
Examples: adult, youth, children, toddler

style_category
Data type: string
Description: Broad fashion category.
Examples: casual, streetwear, athletic, formal, luxury

---

STRUCTURAL FEATURES

fit_type
Data type: string
Description: Overall fit of the garment.
Examples: slim, regular, relaxed, oversized, tailored

length
Data type: string
Description: Relative garment length.
Examples: cropped, waist length, hip length, knee length, full length

sleeve_type
Data type: string
Description: Sleeve configuration.
Examples: sleeveless, short sleeve, three-quarter sleeve, long sleeve, raglan sleeve

collar_type
Data type: string
Description: Neck or collar style.
Examples: crew neck, v-neck, polo collar, hooded, lapel collar, turtleneck

hem_type
Data type: string
Description: Bottom edge finishing.
Examples: straight hem, curved hem, ribbed hem, raw hem

closure_type
Data type: string
Description: Primary fastening mechanism.
Examples: none, zipper, buttons, snaps, drawstring, wrap

waist_structure
Data type: string
Description: Waist construction type.
Examples: elastic waistband, tailored waist, drawstring waist, none

shoulder_structure
Data type: string
Description: Shoulder design.
Examples: structured shoulder, relaxed shoulder, raglan shoulder, dropped shoulder

panel_construction
Data type: string
Description: Panel or seam layout of garment pieces.
Examples: single panel, multi-panel, paneled design

---

MATERIAL AND FABRIC

fabric_type
Data type: string
Description: Dominant fabric type.
Examples: cotton, denim, wool, polyester, nylon, linen, leather, fleece

fabric_weight
Data type: string
Description: Perceived fabric thickness.
Examples: lightweight, medium weight, heavyweight

stretch_level
Data type: string
Description: Degree of stretch in fabric.
Examples: none, low, moderate, high

fabric_texture
Data type: string
Description: Surface structure of fabric.
Examples: knit, woven, ribbed, quilted, brushed, smooth

fabric_finish
Data type: string
Description: Surface treatment or finishing process.
Examples: matte, glossy, washed, distressed finish

lining
Data type: boolean
Description: Whether the garment contains a lining.
Examples: true, false

insulation
Data type: string
Description: Insulating properties of garment.
Examples: none, light insulation, heavy insulation

---

VISUAL DESIGN FEATURES

primary_color
Data type: string
Description: Dominant garment color.
Examples: black, blue, beige

secondary_color
Data type: string or null
Description: Secondary visible color if present.
Examples: white, red, null

color_palette
Data type: array<string>
Description: Full list of colors present in garment.
Examples: ["black","white"]
["navy","grey"]

pattern_type
Data type: string
Description: Visual pattern type.
Examples: solid, striped, plaid, floral, camouflage, graphic

pattern_scale
Data type: string
Description: Relative pattern size.
Examples: small, medium, large

graphic_elements
Data type: string or null
Description: Printed graphics or visual designs.
Examples: chest logo, full graphic print, none

embroidery
Data type: boolean
Description: Presence of embroidered details.
Examples: true, false

distressing
Data type: string
Description: Intentional wear effects.
Examples: none, light distressing, heavy distressing

branding
Data type: string or null
Description: Visible brand mark or logo placement.
Examples: chest logo, sleeve logo, label tag

---

DESIGN DETAILS

pockets
Data type: string
Description: Pocket type and placement.
Examples: kangaroo pocket, side pockets, chest pocket, none

stitching_style
Data type: string
Description: Visible seam or stitching style.
Examples: double stitch, single seam, reinforced seam

buttons_type
Data type: string or null
Description: Button style if present.
Examples: metal buttons, plastic buttons, snap buttons

zippers
Data type: string or null
Description: Zipper presence and placement.
Examples: front zipper, pocket zipper, none

drawstrings
Data type: boolean
Description: Presence of drawstrings.
Examples: true, false

vents
Data type: string or null
Description: Vent placement.
Examples: side vents, back vent, none

cuffs
Data type: string
Description: Cuff construction.
Examples: ribbed cuffs, button cuffs, elastic cuffs

ribbing
Data type: string or null
Description: Ribbed sections of garment.
Examples: hem ribbing, cuff ribbing, collar ribbing

patches
Data type: string or null
Description: Decorative or structural patches.
Examples: elbow patches, logo patch

---

SILHOUETTE GEOMETRY

silhouette_type
Data type: string
Description: Overall garment silhouette shape.
Examples: boxy, fitted, A-line, straight

shoulder_width
Data type: string
Description: Relative shoulder width appearance.
Examples: narrow, regular, wide

torso_width
Data type: string
Description: Relative torso width.
Examples: slim, regular, wide

hem_width
Data type: string
Description: Relative width at hem.
Examples: narrow, regular, wide

drape
Data type: string
Description: Fabric fall and movement.
Examples: structured, soft drape, fluid drape

volume
Data type: string
Description: Amount of garment bulk or fullness.
Examples: low, medium, high

---

WEAR LEVEL

wear_level
Data type: string
Description: Overall visible wear condition.
Examples: new, lightly worn, worn, heavily worn

damage_type
Data type: string or null
Description: Visible damage type if present.
Examples: tear, stain, none

fading
Data type: string
Description: Degree of color fading.
Examples: none, light, moderate, heavy

stretching
Data type: string
Description: Visible stretching deformation.
Examples: none, minor, moderate

holes
Data type: boolean
Description: Presence of holes.
Examples: true, false

fraying
Data type: string
Description: Edge fiber fraying.
Examples: none, light, heavy

---

SEASONALITY

insulation_level
Data type: string
Description: Thermal warmth level.
Examples: low, medium, high

breathability
Data type: string
Description: Airflow characteristics.
Examples: low, medium, high

layering_potential
Data type: string
Description: Suitability for layering.
Examples: base layer, mid layer, outer layer

---

STYLE CONTEXT

aesthetic
Data type: string
Description: Fashion aesthetic category.
Examples: streetwear, minimal, athletic, vintage, luxury

occasion
Data type: string
Description: Intended use scenario.
Examples: casual, sportswear, formal, outdoor

trend_alignment
Data type: string
Description: Alignment with current fashion trends.
Examples: timeless, trending, retro revival

era_style
Data type: string
Description: Era influence of design.
Examples: 90s, 2000s, contemporary

---

TRANSFORMATION RELEVANT ATTRIBUTES

material_reusability
Data type: string
Description: How reusable the fabric is for redesign.
Examples: low, medium, high

fabric_area_estimate
Data type: string
Description: Estimated amount of usable fabric.
Examples: small, medium, large

structural_complexity
Data type: string
Description: Complexity of garment construction.
Examples: simple, moderate, complex

alteration_feasibility
Data type: string
Description: Ease of modifying garment.
Examples: easy, moderate, difficult

---

EXAMPLE JSON OUTPUT

{
"product_description": "Black oversized cotton hoodie with kangaroo pocket and ribbed cuffs",
"identify_materials": ["cotton"],
"identify_brand": null,
"color_palette": ["black"],
"garment_name": "Oversized Hoodie",
"garment_type": "hoodie",
"sub_type": "pullover hoodie",
"gender_target": "unisex",
"age_category": "adult",
"style_category": "streetwear",
"fit_type": "oversized",
"length": "hip length",
"sleeve_type": "long sleeve",
"collar_type": "hooded",
"hem_type": "ribbed hem",
"closure_type": "none",
"waist_structure": "none",
"shoulder_structure": "dropped shoulder",
"panel_construction": "multi-panel",
"fabric_type": "cotton fleece",
"fabric_weight": "medium weight",
"stretch_level": "moderate",
"fabric_texture": "brushed knit",
"fabric_finish": "matte",
"lining": false,
"insulation": "light insulation",
"primary_color": "black",
"secondary_color": null,
"pattern_type": "solid",
"pattern_scale": "none",
"graphic_elements": null,
"embroidery": false,
"distressing": "none",
"branding": null,
"pockets": "kangaroo pocket",
"stitching_style": "double stitch",
"buttons_type": null,
"zippers": null,
"drawstrings": true,
"vents": null,
"cuffs": "ribbed cuffs",
"ribbing": "hem and cuff ribbing",
"patches": null,
"silhouette_type": "boxy",
"shoulder_width": "wide",
"torso_width": "wide",
"hem_width": "regular",
"drape": "soft drape",
"volume": "medium",
"wear_level": "lightly worn",
"damage_type": null,
"fading": "none",
"stretching": "none",
"holes": false,
"fraying": "none",
"insulation_level": "medium",
"breathability": "medium",
"layering_potential": "mid layer",
"aesthetic": "streetwear",
"occasion": "casual",
"trend_alignment": "timeless",
"era_style": "contemporary",
"material_reusability": "high",
"fabric_area_estimate": "large",
"structural_complexity": "moderate",
"alteration_feasibility": "easy"
}


''';

