---
typora-root-url: Img
---

# Snow coverage shader for Unity

This is a part of my exploration into snow shaders in Unity.

This shader is supposed to simulate the effect of objects being covered by snow.

### Outline of the shader's capabilities

- Covers objects with snow from a desired direction. When the object is rotated, the snow recalculates to fit the direction, allowing level designers to focus on their work and not the technicalities of shaders.
- Allows the user to alter the amount of snow that covers the object from the specified direction.
- The snow can have a simple color or a colored texture and can be emissive. Useful for setting a specific 'tone' of the scene.
- The snow can form 'snow caps' with vertex displacement, with the displacement values and expansion of the snow caps being modifiable.
- The effect is purely visual and has no impact on physics.



### Samples

![The effect applied to a free rock asset](/RockWithSnow.gif)

Fig 1. Here the shader has been applied to a rock asset (from a free asset package **Rock package** by [shui861wy](https://assetstore.unity.com/publishers/33764) available at https://assetstore.unity.com/packages/3d/props/exterior/rock-package-118182). You can see the snow positioning itself to fit the desired direction.



![The effect applied to a low poly building](/BuildingWithSnow.gif)

Fig 2. Using the shader with a (relatively) low poly building mesh (from a free asset RPG Poly Pack Lite by [GGigel](https://assetstore.unity.com/publishers/42095) available at https://assetstore.unity.com/packages/3d/environments/landscapes/rpg-poly-pack-lite-148410).  



### Planned features (no time estimate):

- Add support for metallic maps.
- Add support work height maps.
- Expand the vertex displacement to work better with low poly meshes.



### Known issues:

- When the mesh has no provided normal map, the base shader does not work correctly. The SnowCover-NoNormals shader can be used to work around this until the issue is fixed.
- For low poly meshes, the vertex displacement might not look great/might create visual artefacts.