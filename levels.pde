class LevelManager {
    Level[] levels;

    int levelNum = 7;
    int currentLevel;

    public LevelManager() {
        levels = new Level[levelNum];
        currentLevel = 0;

        // make levels
        levels[0] = new Level0();
        levels[1] = new Level1();
        levels[2] = new Level2();
        levels[3] = new Level3();
        levels[4] = new Level4();
        levels[5] = new Level5();
        levels[6] = new Level6();
    }


    boolean hasPrevious() {
        if (currentLevel > 0 && levels[currentLevel-1] != null) return true;
        return false;
    }

    boolean hasNext() {
        if (currentLevel < levels.length - 1 && levels[currentLevel+1] != null) return true;
        return false;
    }

    Level getPrevious() {
        if (hasPrevious()) return levels[currentLevel-1];
        return null;
    }

    Level getNext() {
        if (hasNext()) return levels[currentLevel+1];
        return null;
    }

    Level getCurrentLevel() {
        return levels[currentLevel];
    }

    boolean goRight() {
        if (hasNext()){ currentLevel++; return true; }
        return false;
    }

    boolean goLeft(){
        if (hasPrevious()){ currentLevel--; return true; }
        return false;
    }

}

class Level {
    int levelWidth = 2000;

    ArrayList<Entity> entities;
    int[] ypos;

    public Level() {
        ypos = new int[levelWidth];
        entities = new ArrayList();
    }

    // generate cacti within the world. Places randomly
    public void generateCacti() {
        int cactiCount = (int)random(8, 16);

        for (int i=0; i < cactiCount; i++) {
            Cactus cactus = new Cactus(0,0);

            cactus.position.x = (int) random(0, levelWidth);
            cactus.position.y = (int) getY(cactus.position.x) - cactus.currentSprite.height + 5;

            entities.add(cactus);
        }
    }

    // method to get Y at any given X for the level generator.
    public float getY(float x) {
        if (x > 0 && x < levelWidth)
            return ypos[(int) x];
        else if (x <= 0) return ypos[0];
        else return ypos[levelWidth- 1];
    }

    // empty method to generate pickups in the world (need?)
    public void generatePickups() {
        ;
    }

}

class Level0 extends Level {
    private int height = 200;

    public Level0() {
        super();
        generateCacti();
        generateEntities();
    }

    public float getY(float x) {
        return height;
    }

    public void generateEntities() {
        this.entities.add(new PistolPickup(1000, (int) getY(1000)));
    }

}
class Level1 extends Level {
    // generate positions at the start for efficiency. effectively makes a sin lookup table

    public Level1() {
        super();

        for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200 + 10 * sin(0.02 * i));
        }

        generateCacti();
        generateEntities();
    }

    public void generateEntities() {
        this.entities.add(new Pterodactyl(700, 50));
    }
}

class Level2 extends Level {
    public Level2() {
        super();

        for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200 + 10 * sin(0.001 * i) + 30 * sin(0.0025 * i + 10) );
        }

        generateCacti();
        generateEntities();
    }

    void generateEntities() {
        this.entities.add(new Pterodactyl(900, 50));
        this.entities.add(new Pterodactyl(1200, 50));
    }

}


class Level3 extends Level {
    public Level3() {
        super();for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200
                             + 30 * sin(0.01 * i + 10)
                             + 15 * sin(0.007 * i));
        }

        generateCacti();
        generateEntities();
    }

    void generateEntities() {
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new Pterodactyl(levelWidth, 50));
        this.entities.add(new ShotgunPickup(300, (int) getY(300)));
    }
}
class Level4 extends Level {
    public Level4() {
        super();for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200 + 10 * sin(0.02 * i) + 30 * sin(0.01 * i + 10) );
        }

        generateCacti();
        generateEntities();
    }

    void generateEntities(){
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new Pterodactyl(1200, 50));
    }
}

class Level5 extends Level {
    public Level5() {
        super();for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200
                             + 20 * sin(0.005 * i + 20)
                             + 40 * sin(0.002 * i));
        }

        generateCacti();
        generateEntities();

    }

    void generateEntities() {
        this.entities.add(new Pterodactyl(levelWidth, 50));
        this.entities.add(new Pterodactyl(1300, 60));
        this.entities.add(new Pterodactyl(1200, 50));
    }
}
class Level6 extends Level {
    public Level6() {
        super();for (int i= 0; i < levelWidth; i++) {
            ypos[i] = (int) (200
                             + 10 * sin(0.001 * i + 10)
                             + 20 * sin(0.01 * i));
        }

        generateCacti();
        generateEntities();
    }
    void generateEntities() {
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new Pterodactyl(1200, 50));
        this.entities.add(new MachineGunPickup(350,(int) getY(350)));
        this.entities.add(new GirlfriendDino(levelWidth-400, (int) getY(levelWidth-400)));
    }
}
