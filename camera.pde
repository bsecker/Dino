
/*
Somewhere else in the code:
(from python) self.camera = Camera(simple_camera, constants.SCREEN_WIDTH,constants.SCREEN_HEIGHT)


 */


class Camera {
    PVector pos;
    int width;
    int height;

    public Camera( int width, int height) {
        pos = new PVector(0, 0);
        this.width = width;
        this.height = height;
    }

    // translate camera position in terms of target.
    void update(PVector target) {
        pos.x = target.x - (width/2);
        pos.y = target.y - (height/2);
    }

    // shake camera
    void shake(int intensity) {
        pos.x += random(-intensity, intensity);
        pos.y += random(-intensity, intensity);
    }
}
