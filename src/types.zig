const rl = @import("raylib");

pub const Object = struct {
    box: rl.Rectangle,
    texture: ?rl.Texture2D,
};

pub const Player = struct {
    box: rl.Rectangle,
    // detection_box: NullOriginBox,
    velocity: rl.Vector2,
    // max_velocity: f32,
};

// const NullOriginBox = struct {
//     height: f32,
//     width:  f32
// };

pub const Map = struct {
    tiles: []Object,
};