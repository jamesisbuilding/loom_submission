const String garmentIdeationPrompt = '''
Use the extracted garment JSON as input context. The model must propose **three realistic redesign options** that could plausibly be created from the original garment using tailoring, cutting, or repurposing.

Return the result strictly as JSON following the schema below.

---

PROMPT

You are a fashion redesign assistant.

You will receive structured JSON describing a garment extracted from an image.

Your task is to propose three realistic redesign concepts showing what the garment could become if it were altered, tailored, or repurposed.

Constraints:

* The redesign must plausibly use the original garment's material.
* Do not invent new fabrics unless minimal additions would realistically occur during tailoring.
* Preserve recognizable aspects of the original garment where possible.
* The redesign should feel achievable through sewing, cutting, tailoring, or repurposing.
* Each option should represent a distinct transformation direction.
* Favor transformations that are fashion-relevant and visually interesting.

Transformation categories should ideally vary between:

* Tailored improvement of the existing garment
* Style transformation into a different garment type
* Functional repurpose into a different wearable or accessory

For each option:

Provide a short concept name, a description of the transformation, the resulting garment type, the key modifications required, and a difficulty estimate.

Return JSON only.

---

OUTPUT JSON SCHEMA

option_id
Data type: integer
Description: Unique identifier for the redesign option.

concept_name
Data type: string
Description: Short human-readable title of the redesign concept.

new_garment_type
Data type: string
Description: Type of garment or item produced from the transformation.

transformation_category
Data type: string
Description: Type of redesign approach.
Examples: tailored_upgrade, style_remix, functional_repurpose

description
Data type: string
Description: Detailed explanation of the redesign and how the original garment becomes the new piece.

key_modifications
Data type: array<string>
Description: Physical changes required to transform the garment.

material_usage
Data type: string
Description: How the original fabric is reused in the transformation.

difficulty
Data type: string
Description: Estimated difficulty level of executing the transformation.
Examples: easy, moderate, advanced

estimated_steps
Data type: integer
Description: Approximate number of steps required to perform the transformation.

visual_style
Data type: string
Description: Fashion aesthetic of the resulting garment.

---

EXAMPLE OUTPUT JSON

{
"transformation_options": [
{
"option_id": 1,
"concept_name": "Cropped Street Hoodie",
"new_garment_type": "cropped hoodie",
"transformation_category": "tailored_upgrade",
"description": "The oversized hoodie is shortened to create a modern cropped silhouette while maintaining the hood, sleeves, and original cotton fleece fabric. The hem is restructured with a new ribbed finish to maintain elasticity.",
"key_modifications": [
"shorten torso length",
"cut and resew hem",
"retain hood and sleeves",
"reshape waistline for cropped fit"
],
"material_usage": "Original cotton fleece fabric retained for the entire garment with minimal additional materials required.",
"difficulty": "easy",
"estimated_steps": 4,
"visual_style": "streetwear"
},
{
"option_id": 2,
"concept_name": "Sleeveless Training Hoodie",
"new_garment_type": "sleepless gym hoodie",
"transformation_category": "style_remix",
"description": "The sleeves are removed and arm openings are reinforced to convert the hoodie into a sleeveless athletic training garment suitable for gym wear.",
"key_modifications": [
"remove sleeves",
"finish arm openings",
"tighten torso fit",
"reinforce seams"
],
"material_usage": "Main body fabric remains unchanged while sleeve fabric may be reused for reinforcement or pocket accents.",
"difficulty": "easy",
"estimated_steps": 3,
"visual_style": "athletic"
},
{
"option_id": 3,
"concept_name": "Upcycled Fabric Tote Bag",
"new_garment_type": "tote bag",
"transformation_category": "functional_repurpose",
"description": "The hoodie body is cut and reassembled into a fabric tote bag while the hood fabric becomes the interior pocket. Sleeves can be used to create carrying straps.",
"key_modifications": [
"cut torso fabric into panels",
"sew rectangular bag structure",
"create straps from sleeve fabric",
"add internal pocket from hood"
],
"material_usage": "Nearly all original fabric is repurposed into bag panels, straps, and pocket lining.",
"difficulty": "moderate",
"estimated_steps": 6,
"visual_style": "sustainable minimal"
}
]
}
''';

