Dinosaur player;
World world;
MessageSystem messages;
Camera camera;
Hud hud;
ParticleSystem particles;

color BG_COL = color(209, 249, 245);

void setup() {
    size(1104, 300, P2D);  
    frameRate(60);
    
    // fullScreen();
    pixelDensity(displayDensity());
    background(BG_COL);

    player = new Dinosaur(640, 340);
    world = new World();
    messages = new MessageSystem();
    camera = new Camera(width, height);
    hud = new Hud();
    particles = new ParticleSystem();

    world.player = player; // set reference to player object
    world.resetLevel();

    // spawn starting entities
    GirlfriendPterodactyl gf = new GirlfriendPterodactyl(700, (int)world.getY(700)-60);
    world.addEntity(gf);
    world.addEntity(new PterodactylEscort(700+(int)random(-20, 20), (int)world.getY(700)+(int)random(-20, 20), gf));
    world.addEntity(new PterodactylEscort(700+(int)random(-20, 20), (int)world.getY(700)+(int)random(-20, 20), gf));
    world.addEntity(new PterodactylEscort(700+(int)random(-20, 20), (int)world.getY(700)+(int)random(-20, 20), gf));

    // say message
    messages.pushMessage("oh no! The Pterodactyls have stolen Princess Diana-saur!");
    messages.pushDelayedMessage("You must get her back!", 50);

}

void draw() {
    background(BG_COL);

    // move camera unless player is near boundary
    if (player.position.x > camera.width/2 && player.position.x < world.getLevelWidth()-(camera.width/2)) camera.update(player.position);


    // handle changing levels if the player moves outside the boundaries
    if (player.position.x > world.getLevelWidth() && world.levelManager.hasNext()) {
        world.goRightLevel();
        player.position.x = 10;
        camera.update(new PVector(camera.width/2, 0));
    }
    if (player.position.x < 0 && world.levelManager.hasPrevious()) {
        world.goLeftLevel();
        player.position.x = world.getLevelWidth() - 10;
        camera.update(new PVector(world.getLevelWidth()-camera.width/2,0));
    }

    // translate everything in the game by the camera using push and pop matrix so that the HUD doesn't get moved
    pushMatrix();
    translate(-camera.pos.x, 0);//-camera.pos.y);
    world.draw();
    particles.update();
    popMatrix();


    // draw HUD
    messages.draw();
    hud.draw(player.health);


}

void keyPressed() {
    if (key == ' ') player.shoot(); 

    // handle movement
    if (key == CODED) {
        switch (keyCode) {
        case LEFT: player.moveLeft(); break;
        case RIGHT: player.moveRight(); break;
        case UP: player.jump(); break;
        case DOWN: player.duck(); break;
        }
    }
}

void keyReleased() {
    if (key == ' ') player.stopShoot();
    if (key == CODED) {
        switch (keyCode) {
        case LEFT: player.stopLeft(); break;
        case RIGHT: player.stopRight(); break;
        case DOWN: player.stopDuck(); break;
        }
    }
}
