class Hud {

    PImage healthSprite;
    PImage gameOverSprite;


    public Hud() {
        healthSprite = loadImage("health.png");
        gameOverSprite = loadImage("gameOver.png");
    }

    public void draw(int health) {
        // draw all healthbars as sprites
        for (int i=0; i<health; i++) {
            // tint(200);
            image(healthSprite, 5+i*20, 5);
            // tint(255);
        }

        // draw game over sprite
        if (health <= 0) {
            image(gameOverSprite, (width/2)-(gameOverSprite.width/2), 100);
        }
    }

}
