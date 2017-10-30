class Sprite{
    // class to handle sprites for each entity. Also does animation
    // all images use .png

    private PImage[] images;
    int imageCount;
    int frame;
    int currentFrame;
    int width;
    int height;

    private int animationSpeed;
    int time = millis();

    /* Create new Sprite.
       Sprite image files must look similar to: imageName-1
       count is the maximum number at the end of the images.
       ie constructing a spaceship sprite with 3 images would be:
       new Sprite('spaceship', 3);
    */
    public Sprite(String imagePrefix, int count, int animSpeed) {
        // if (count == 0) throw new Exception("Sprite must have at least 1 image");
        images = new PImage[count];
        imageCount = count;
        animationSpeed = animSpeed;

        // add images to list
        for (int i= 1; i < count+1; i++) {
            images[i-1] = loadImage(imagePrefix+"-"+i+".png");
        }
        
        // set width and height
        width = images[0].width;
        height = images[0].height;

        currentFrame = 0;
    }

    public Sprite(String imagePrefix, int count) {
        this(imagePrefix, count, 200);
    }

    void draw(float x, float y) {
        draw(x, y, false);
    }

    // draw normal or flipped sprite at x,y
    void draw(float x, float y, boolean flipped) {
        draw(x, y, flipped, 1);
    }

    void draw(float x, float y, boolean flipped, int scale) {
        // animate image if animation speed is not 0
        if (animationSpeed != 0 && millis() > time + animationSpeed){
            currentFrame ++;
            time = millis();
        }
        if (currentFrame >= imageCount) currentFrame = 0;

        // draw image
        if (!flipped) drawSingularImage(currentFrame, x, y, scale);
        else {
            pushMatrix();
            scale(-1.0, 1.0);
            drawSingularImage(currentFrame , -x-images[0].width, y, scale);
            popMatrix();
        }
    }

    // helper function to draw singular image from images array
    private void drawSingularImage(int imagesIndex, float x, float y, float scale){
        image(images[imagesIndex], x, y/*-images[imagesIndex].height/2*/, images[imagesIndex].width* scale, images[imagesIndex].height * scale);
    }

    // need this?
    int getWidth() {
        return images[0].width;
    }

    public void setImage(int index) {
        currentFrame = index;
    }
}
