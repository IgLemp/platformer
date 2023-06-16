const rl = @import("raylib");

pub fn GetMousePositionWS(camera: rl.Camera2D, screenWidth: f32, screenHeight: f32) rl.Vector2 {
    var mouse_position = rl.GetMousePosition();

    // wold space position vectors for left-top and right-botton respectivly
    var ws_position_vector_lt: rl.Vector2 = .{ .x = camera.target.x - (screenWidth / 2) * (1 / camera.zoom), .y = camera.target.y - (screenHeight / 2) * (1 / camera.zoom)};
    var ws_position_vector_rb: rl.Vector2 = .{ .x = camera.target.x + (screenWidth / 2) * (1 / camera.zoom), .y = camera.target.y + (screenHeight / 2) * (1 / camera.zoom)};
    
    // range vector of distances of screen height and width translated to worldspace coordinates
    var ws_position_vector_range: rl.Vector2 = .{ .x = ws_position_vector_rb.x - ws_position_vector_lt.x, .y = ws_position_vector_rb.y - ws_position_vector_lt.y};
    
    // mouse position vector but it's a range between 0 and 1
    var scaled_mouse_position_vector: rl.Vector2 = .{ .x = mouse_position.x / screenWidth, .y =  mouse_position.y / screenHeight};

    return .{ .x = ws_position_vector_lt.x + scaled_mouse_position_vector.x * ws_position_vector_range.x, .y = -(ws_position_vector_lt.y + scaled_mouse_position_vector.y * ws_position_vector_range.y)};
}