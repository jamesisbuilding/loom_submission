![RESTITCH](images/RESTITCH%20by.png)

### Loom Submission - James Potter


### Target User
I have created short demo app called 'RESTITCH'. An AI-enabled work flow to get design inspiration from your clothing garments. 
This is for people who are aware of the 'redesigning / re-purposing' services available but are 

1. Not fully aware of the potential options they have when it comes to repurposing (need inspiration)
2. Are doubtful or not fully aligned with the re-purpose culture and still want that 'luxury' feel. 

As such Restitch attempts to frame the repurpose trend with more of a luxury feel via it's design. 

### Screen by Screen Explanation

### 1. Entry Screen
The current entry screen features a simple RESTITCH rotating text logo. Looking forward, I would evolve this to more closely resemble the cover of a luxury fashion magazine—with a striking top banner, eye-catching imagery of past garment transformations (sourced from either users or in-house examples), and an integrated dashboard showing users the status and history of their transformation orders, so everything is accessible in one place. With more time and resources, my focus would be on amplifying the wow factor and infusing the app with an aura of elegance, trust, and luxury right from the beginning.

From a UX perspective, the entry screen introduces two custom shaders: a wave-style motif in our brand’s core color palette, and a grain texture to counteract the typical flat/digital feel of mobile screens—adding warmth and personality. A subtle blur effect further enhances contrast between text, buttons, and background, creating a layered, tactile experience.

When the user taps 'START RESTITCHING', a custom animation is triggered: the background blurs, the text expands, the main button transforms, and the 'Upload Garment Image' button appears with a custom icon (currently reminiscent of a cleaning logo; ultimately, I intend to replace this with an animated GIF showing garments morphing and blending into each other).

At the bottom of this entry screen, I would also add a dedicated section or panel where users can input and view their full specifications—such as body measurements, an image of themselves, and any other information that might be relevant to personalized fashion transformations. This ensures the app can deliver outputs that are uniquely tailored, and brings a more "couture" feel to the experience.

### 2. Upload Screen 
Our upload screen holds our 'Upload Garment Image' button, which has a shimmer effect when no image is uploaded. When an image is uploaded from gallery, it updates 
the colours of our background to match the palette of the garment image, bringing the app alive and dynamic; reacting to the user's inputs. Note: for all buttons I have 
added a custom shrink/expand on tap, to give that interactive feel - these also have haptic feedback. And for the uploaded image container has gyro parallax so it moves 
based on the position of the user's phone. 

Upon upload the user can click 'Generate Variations' to start the generation process. 

In this screen I would add a few things; 
1. Initial garment analysis - I would have an image analysis model actually return a preliminary analysis of the garment, showing the user important information - you can actually see the full prompt I would use in [core/services/garment_transformation_service/lib/src/data/prompts/garment_analysis_prompt.dart]. I have kept it so we use the thin prompt for now due to time restrictions. 

2. Full pre-generation options. I would give the user full control over the output should they desire. They can choose the number of output images, season or style they would like to design into, upload complementary clothing items that they want this new redesign to match, upload inspiration clothing item images that they want their redesign to emulate and also add in an image of themselves so they can customise the output images. Full output customisation can also be the type of images created; studio product shots, in-vivo lifestyle shots, 
up close material shots, hero shots and any kind of e-commerce shot should they wish. 

3. LLM Chat integration - I would also refactor the pipeline such that instead of a single flow of pressing a button and getting an output, the user can chat directly with our 
design-AI, 'Versac-ai' or 'Gucc-ai' come to mind as tongue-in-cheek names. Where our AI would analyse and give pre-generation options in natural language, acting as a fashion 
concierge and giving more of that luxury feel. 


### Loading Screen 
Here the user's garment is segmented out, animated with a pulse and overlayed over a wave-style animation which is coloured based on the uploaded garment image too. At the bottom of the screen we have 
our custom text showing loading.

In this screen I would add
1. Clear stages of loading. Right now there are 3 distinct steps in our pipeline, we can show the user clearly which stage the pipeline is on and how many images have been created 
to give more of a sense of progression. 

2. I would add a better animation showing the garment being morphed into new shapes, framing the user's expectations as to what is to come. 


### Results Screen 
Here the user sees their output in a custom FadezCarousel I previously created. Users can swipe through their options, like, share, and submit a request for this garment to be remade.

To enrich this screen, here is the additional information and features I would include:

1. Transform the UI layout to resemble a luxury ecommerce storefront, where each generated garment variation appears as a refined product listing with prominent imagery, detailed information, and call-to-action buttons to request a remake or add to wishlist.

2. For each output, display multiple images per redesign to offer a comprehensive view:
    - Main studio shots (front, back, left, right)
    - Hero shots (especially if the user uploaded a photo of themselves, showcasing virtual try-on capability with the user's image or a virtual mannequin)
    - Material/fabric close-ups
    - Lifestyle/in-context shots
    - Packaging shots (if packaging or presentation is a service offering)
    - Allow toggling between these image types for a richer exploration of each garment.

3. Present clear and extensive details for each redesign:
    - Name
    - Description
    - Ease / Difficulty of construction
    - Estimated production time
    - Estimated pricing/cost
    - Suggested outfit pairings or complementary products

4. Provide additional value-added insights and functionality:
    - Comprehensive material and fabric analysis (covering both the original and suggested redesign)
    - Sustainability metrics (e.g., waste saved, upcycling/environmental impact)
    - Sizing and fit recommendations (potentially inferred from user input or advanced garment analysis)
    - Designer/AI commentary explaining creative choices and inspiration
    - Customer reviews and ratings for similar redesigns
    - Download and share functionality for design specs, inspiration boards, and images
    - Feedback mechanism, enabling users to request further tweaks or customization per variation

5. Enhance user experience and interaction with advanced options:
    - Virtual try-on capability, enabling users to see the redesign on a mannequin or on a user-uploaded photo, facilitating a personalized preview experience
    - Filters and sorting to explore generated designs by style (casual, formal, avant-garde, etc.)
    - Side-by-side comparison tools for the original and all redesign variants
    - Ability to favorite/shortlist preferred outputs for easy access later

6. Strengthen service transparency and inspire confidence:
    - Prominent "Request a Consultation" button to directly connect users with an expert
    - Clearly presented information about shipping, returns, remaking, and service policies
    - Inspiration gallery highlighting successful redesigns from other users

By integrating these features—including multi-angle galleries per variation and immersive virtual try-ons—the results screen would offer an elevated, dynamic, and deeply personalized luxury shopping experience befitting a high-end fashion platform.

---

**Recreation Methodology:**  
Additionally, I would include a dedicated section for each redesign labeled "Recreation Methodology." This section would provide a tentative, step-by-step explanation of exactly how the selected garment could be transformed into its new design. This would outline the proposed techniques for deconstruction, materials needed, recommended construction methods, expected challenges, and any considerations or recommendations for achieving the envisioned transformation. This transparency not only helps communicate the craftsmanship and process behind each redesign but also empowers users (and makers) with insight into how their unique garment can be successfully recreated. This would be useful for both the user and the designer to have transpreancy over the re-creation process. 



## AI Integration 
I have done a very small pipeline to generate images now. It uses a an interface whereby we can use a dummy, chatgpt, or gemini implementation to generate images. 

Here we have 3 steps
1. Analyse the image - extract out information of the uploaded garment. This can be built out fully to show the user our system fully understands the garment and gives 
them meaningful insights into how it can be transformed. 

2. Ideation - the pipeline then creates 3 ideas that the item can be transformed into. For now I have done this is a hard-coded examples however it would infact take in the user's preferences and take into account things like their build, existing style choices, current trends and user-uploaded inspiration to create fully flrshed out and personalised ideas. 

3. Generation - based on the ideas and input garment image, generate the new garment with our specifications and return our images to be shown. 


However, I have drafted out a large flow I would like to put into the app - this weavy implementation shows a more fleshed-out approach which can easily be ported over to flutter. 
[weavy flow](https://app.weavy.ai/flow/5QUfbeLoSwtwASNyLNGCrK)

The full flow I would like to implement 

### User
1. Take in user garment image 
2. (Optional) take in user image to show output of outfit 
3. Generate 3 bespoke ideas for transformation based on the user's preferences; style, seasonlity, build, existing outfit choices, current industry trends 
4. Return to the user a full 'transformation' package that shows the output not as a single image but as a bespoke e-commerce style experience including but not limited to
    - Studio shots (front, left, right, back) of the garment alone 
    - The user wearing the outfit (front, left, right, back)
    - Fabric close ups 
    - Packaging examples with Loom branding 
    - All output explained in the results screen section 
5. Virutal try on (example in flow in weavy)

### For Designer

1. Detailed, step-by-step recreation methodology for each transformation, including recommended deconstruction, materials, construction techniques, and considerations (potential challenges, tools required, etc.)
2. Downloadable technical specification sheets for each redesign, summarizing key garment dimensions, style references, and material lists
3. Access to high-resolution, multi-angle reference images (front, side, back, fabric close-ups) of the original and transformed garment
4. AI-generated pattern suggestions or construction plan drafts (when feasible)
5. Notes on any special finishes, printing, embroidery, or branding details referenced in the concept
6. A feedback and annotation tool allowing the designer to pin notes or questions on redesign images or methodology steps
7. Option for direct chat or consultation with the client for clarifications or custom requests
8. Quick access to the client’s submitted preferences, measurements, and inspiration uploaded in the ideation stage