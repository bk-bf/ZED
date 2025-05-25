extends Node

# Keep the organizational structure but change implementation
var cached_placeholders: Dictionary = {}
var environment_tilemap: TileMap
var entity_multimeshes: Dictionary = {}

func _ready():
    setup_tilemap_system()
    setup_multimesh_system()
    generate_placeholder_materials()

func generate_placeholder_materials():
    # Generate materials for all MultiMesh instances
    create_character_materials()
    create_weapon_materials()
    create_item_materials()
    create_effect_materials()

func create_character_materials():
    # Player material
    var player_material = create_colored_material(Color.BLUE, "player")
    entity_multimeshes["player"].material = player_material
    
    # Zombie material
    var zombie_material = create_colored_material(Color.RED, "zombie")
    entity_multimeshes["zombie"].material = zombie_material
    
    # Survivor material
    var survivor_material = create_colored_material(Color.GREEN, "survivor")
    entity_multimeshes["survivor"].material = survivor_material

func create_weapon_materials():
    # Pistol material
    var pistol_material = create_colored_material(Color.YELLOW, "pistol")
    entity_multimeshes["pistol"].material = pistol_material
    
    # Rifle material
    var rifle_material = create_colored_material(Color.ORANGE, "rifle")
    entity_multimeshes["rifle"].material = rifle_material
    
    # Shotgun material
    var shotgun_material = create_colored_material(Color.PURPLE, "shotgun")
    entity_multimeshes["shotgun"].material = shotgun_material

func create_item_materials():
    # Loot material
    var loot_material = create_colored_material(Color.CYAN, "loot")
    entity_multimeshes["loot"].material = loot_material
    
    # Projectile material
    var projectile_material = create_colored_material(Color.WHITE, "projectile")
    entity_multimeshes["projectile"].material = projectile_material

func create_effect_materials():
    # Blood splatter material
    var blood_material = create_colored_material(Color.DARK_RED, "blood")
    if "blood" in entity_multimeshes:
        entity_multimeshes["blood"].material = blood_material
    
    # Muzzle flash material
    var flash_material = create_colored_material(Color.YELLOW, "muzzle_flash")
    if "muzzle_flash" in entity_multimeshes:
        entity_multimeshes["muzzle_flash"].material = flash_material

func create_colored_material(color: Color, material_name: String) -> CanvasItemMaterial:
    var material = CanvasItemMaterial.new()
    material.albedo_color = color
    
    # Add subtle border effect for better visibility
    material.flags_unshaded = true
    material.flags_do_not_receive_shadows = true
    
    # Cache for potential reuse
    cached_placeholders[material_name + "_material"] = material
    
    return material

# Helper function to get cached materials
func get_material(material_name: String) -> CanvasItemMaterial:
    return cached_placeholders.get(material_name + "_material", null)

# Function to update material colors at runtime (useful for status effects)
func update_material_color(entity_type: String, new_color: Color):
    if entity_type in entity_multimeshes:
        var material = entity_multimeshes[entity_type].material as CanvasItemMaterial
        if material:
            material.albedo_color = new_color

func setup_tilemap_system():
    environment_tilemap = TileMap.new()
    add_child(environment_tilemap)
    
    var tileset = TileSet.new()
    
    # Use the color scheme from first reply but implement as tiles
    create_tile_source(tileset, 0, Color.LIGHT_GRAY, "floor")
    create_tile_source(tileset, 1, Color.DIM_GRAY, "wall")
    create_tile_source(tileset, 2, Color.SADDLE_BROWN, "door_closed")
    create_tile_source(tileset, 3, Color.BURLYWOOD, "door_open")
    create_tile_source(tileset, 4, Color.LIGHT_BLUE, "window")
    
    environment_tilemap.tile_set = tileset

func setup_multimesh_system():
    # Characters
    entity_multimeshes["player"] = create_entity_multimesh(Color.BLUE, 1)
    entity_multimeshes["zombie"] = create_entity_multimesh(Color.RED, 1000)
    entity_multimeshes["survivor"] = create_entity_multimesh(Color.GREEN, 50)
    
    # Weapons (floating above characters)
    entity_multimeshes["pistol"] = create_weapon_multimesh(Color.YELLOW, Vector2(16, 8), 100)
    entity_multimeshes["rifle"] = create_weapon_multimesh(Color.ORANGE, Vector2(32, 8), 100)
    entity_multimeshes["shotgun"] = create_weapon_multimesh(Color.PURPLE, Vector2(28, 12), 100)
    
    # Loot and items
    entity_multimeshes["loot"] = create_entity_multimesh(Color.CYAN, 200)
    entity_multimeshes["projectile"] = create_entity_multimesh(Color.WHITE, 500)

func create_tile_source(tileset: TileSet, id: int, color: Color, type: String):
    var source = TileSetAtlasSource.new()
    
    # Create the colored texture efficiently
    var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
    image.fill(color)
    
    # Add visual indicators from first reply but optimized
    match type:
        "door_closed":
            add_door_handle(image)
        "window":
            add_window_cross(image)
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    
    source.texture = texture
    source.create_tile(Vector2i(0, 0))
    tileset.add_source(source, id)

# Keep these helper functions from first reply
func add_door_handle(image: Image):
    var handle_color = Color.GOLD
    for x in range(28, 32):
        for y in range(14, 18):
            image.set_pixel(x, y, handle_color)

func add_window_cross(image: Image):
    var frame_color = Color.WHITE
    for x in range(8, 24):
        image.set_pixel(x, 16, frame_color)
    for y in range(8, 24):
        image.set_pixel(16, y, frame_color)

func create_weapon_multimesh(color: Color, size: Vector2, max_instances: int) -> MultiMeshInstance2D:
    var multimesh_instance = MultiMeshInstance2D.new()
    add_child(multimesh_instance)
    
    var multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_2D
    multimesh.instance_count = max_instances
    
    # Create weapon-shaped quad
    var quad_mesh = QuadMesh.new()
    quad_mesh.size = size # Different sizes for different weapons
    
    var material = CanvasItemMaterial.new()
    material.albedo_color = color
    
    multimesh.mesh = quad_mesh
    multimesh_instance.multimesh = multimesh
    multimesh_instance.material = material
    
    return multimesh_instance

func create_entity_multimesh(color: Color, max_instances: int) -> MultiMeshInstance2D:
    var multimesh_instance = MultiMeshInstance2D.new()
    add_child(multimesh_instance)
    
    var multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_2D
    multimesh.instance_count = max_instances
    
    var quad_mesh = QuadMesh.new()
    quad_mesh.size = Vector2(32, 32) # Standard character size
    
    var material = CanvasItemMaterial.new()
    material.albedo_color = color
    
    multimesh.mesh = quad_mesh
    multimesh_instance.multimesh = multimesh
    multimesh_instance.material = material
    
    return multimesh_instance
