import java.util.Map;

class World {
    private float worldY = 200;

    PImage backgroundLine = loadImage("ground.png");

    private ArrayList<Entity> entities;
    private ArrayList<Bullet> bullets;

    public Dinosaur player;
    public Entity girlfriend;
    boolean gameOver = false;

    private LevelManager levelManager;

    public World() {
        entities = new ArrayList();
        bullets = new ArrayList();
        levelManager = new LevelManager();
    }

    public void goRightLevel() {
        if (levelManager.goRight())
            resetLevel();
    }

    public void goLeftLevel() {
        if (levelManager.goLeft())
            resetLevel();
    }

    public void resetLevel() {
        entities.clear();
        bullets.clear();

        addEntity(player);

        if (girlfriend != null) {
            girlfriend.position.x = world.getLevelWidth() - 10;
            addEntity(girlfriend);
        }
        generateEntitiesFromLevel();
        generateClouds(4);
    }



    // return y at any given x
    public float getY(float x) {
        return levelManager.getCurrentLevel().getY(x);
    }

    public float getLevelWidth() {
        return levelManager.getCurrentLevel().levelWidth;
    }

    public void draw() {
        // draw repeating background line
        // for (int i=0; i<3; i++) {
        //     image(backgroundLine, i * backgroundLine.width, getY(0)-10);
        // }

        // generate clouds randomly
        if ((int)random(0,500) == 1) addEntity(new Cloud((int)getLevelWidth(), (int)random(0, 100)));

        // use vertical lines to draw colours. also draw level
        for (int x = 1; x < getLevelWidth(); x ++) {
             stroke(219, 190, 140);
             line(x, getY(x), x, height);
             stroke(0);
            line(x-1, getY(x-1), x, getY(x));
        }

        // update and draw in the same method to have less for loops!

        // draw/update entities (iterate backwards to prevent concurrent modification)
        for (int i = entities.size() - 1; i >= 0; i--) {
            Entity entity = entities.get(i);
            entity.update();
            entity.draw();


            if (entity.alive == false) entities.remove(entity);
        }

        // draw/update bullets (iterate backwards to prevent concurrent modification)
        for (int i = bullets.size() - 1; i >= 0; i--) {
            Bullet bullet = bullets.get(i);
            bullet.update();
            bullet.checkCollision(entities);
            bullet.draw();

            if (bullet.alive == false) bullets.remove(bullet);
        }


        // randomly create dinosaurs on the way back
        if (girlfriend != null && gameOver == false) {
            int rand = (int) random(400);
            if (rand == 1) addEntity(new Pterodactyl((int)getLevelWidth(), 0));
            else if (rand == 2) addEntity(new Pterodactyl(0, (int) random(0, 30)));
        }

    }

    public void generateCacti(int count) {
        for (int i=0; i < count; i++) {
            int x = (int) random(0, getLevelWidth());
            addEntity(new Cactus(x, (int) getY(x)));
        }
    }

    public void generateEntitiesFromLevel() {
        for (Entity i: levelManager.getCurrentLevel().entities) {
            addEntity(i);
        }
    }

    public void generateClouds(int count) {
        for (int i=0; i<count; i++) {
            addEntity(new Cloud((int) random(0,getLevelWidth()), (int)random(10, worldY/2)));
        }
    }

    public void addEntity(Entity entity) {
        entities.add(entity);
    }

    public void removeEntity(Entity entity) {
        entity.alive = false; // mark dead so that it can be removed next loop
    }

    public void addBullet(Bullet bullet) {
        bullets.add(bullet);
    }

    public void addPickup(WeaponPickup pickup) {
      entities.add(pickup);
    }

}
