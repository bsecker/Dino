class Entity {
    PVector position;
    PVector velocity;
    PVector accel;
    float mass;

    boolean alive;
    int health;

    Sprite currentSprite;
    EquippedWeapon currentWeapon;
    boolean following;

    public Entity(int x, int y) {
        position = new PVector(x,y);
        velocity = new PVector(0,0);
        accel = new PVector(0,0);
        mass = 1;
        alive = true;
    }

    void update() {
        velocity.add(accel);
        position.add(velocity);
        accel.mult(0);
    }

    void draw() {
        if (currentSprite != null)
         currentSprite.draw(position.x, position.y);
    }

    void applyForce(PVector force) {
        accel.add(PVector.div(force, mass));
    }

    String toString() {
      return (this.getClass().getName() + " at Position: "+position.x+" "+position.y);
    }
}

class Dinosaur extends Entity {
    // set up sprites for dinosaur.
    Sprite idle;
    Sprite moving;
    Sprite ducking;
    Sprite dead;

    // weapons
    EquippedWeapon currentWeapon;

    // constants
    float moveSpeed = 1;
    float maxMoveSpeed = 4;
    float terminalVelocity = 10;
    int jumpSpeed = 10;
    float gravityAccel = 0.5;

    // movement/actions
    direction dir;
    boolean leftPressed;
    boolean rightPressed;
    boolean duckPressed;
    boolean shooting;

    public Dinosaur(int x, int y) {
        super(x, y);

        idle = new Sprite("dinosaur",1);
        moving = new Sprite("dinoMove/dinosaurMove", 2);
        ducking = new Sprite("dinoDuck/dinosaurDuck", 2);
        dead = new Sprite("dinosaurDead", 1, 0);
        mass = 1;
        dir = direction.RIGHT;
        health = 10;

        leftPressed = false;
        rightPressed = false;
        duckPressed = false;

        currentSprite = moving;
        currentWeapon = null;
    }

    public void update() {
        // apply gravity force
        applyForce(new PVector(0, gravityAccel));

        // apply friction
        PVector friction = new PVector(velocity.x, 0);
        friction.mult(-1);
        friction.normalize();
        friction.mult(Constants.FRICTION_COEFFICIENT);
        applyForce(friction);

        // limit y position
        if (isOnGround()) {
            velocity.y = 0;
            position.y = world.getY(position.x) - currentSprite.height;
        }

        // limit x
        if (velocity.x > terminalVelocity) velocity.x = terminalVelocity;
        if (velocity.x < -terminalVelocity) velocity.x = -terminalVelocity;

        // apply movements and make particles
        if (leftPressed && velocity.x > -maxMoveSpeed && health > 0) {
            applyForce(new PVector(-moveSpeed, 0));
            if (isOnGround())particles.addTrail(position.x+currentSprite.width/2, position.y+currentSprite.height, velocity.get().mult(-1));
        }
        if (rightPressed && velocity.x < maxMoveSpeed && health > 0) {
            applyForce(new PVector(moveSpeed, 0));
            if (isOnGround())particles.addTrail(position.x+currentSprite.width/2, position.y+currentSprite.height, velocity.get().mult(-1));
        }

        // apply animations
        if ((leftPressed || rightPressed) && isOnGround()) currentSprite = moving; // moving
        if (abs(velocity.x) < 1 && !duckPressed) currentSprite = idle; // idle, not moving
        if (!isOnGround()) currentSprite = idle;
        if (duckPressed) currentSprite = ducking;
        if (health <= 0) currentSprite = dead;

        // update weapons
        if (currentWeapon != null) {
            currentWeapon.update(new PVector(this.position.x + this.currentSprite.width/2,
                                             this.position.y + this.currentSprite.height/2),
                                 this.dir);
        }

        checkPickups();

        // shoot gun
        if (shooting) shootEquipped();
        
        // if (health <= 0) alive=false;

        super.update();
    }

    public void checkPickups() {
        for (int i = world.entities.size() - 1; i >= 0; i--) {
            Entity entity = world.entities.get(i);
            if (entity instanceof Dinosaur) continue;

            // near entity
            if (abs(entity.position.x+entity.currentSprite.width/2 - this.position.x) < 3 ) {
                if (entity instanceof WeaponPickup) pickup(entity);
                if (entity instanceof GirlfriendDino) {
                    if (!entity.following) {
                        messages.pushMessage("You got princess diana-saur! bring her back!");
                        messages.pushDelayedMessage("RUN!!!", 100, 300, messageType.URGENT);

                        // immediately spawn a few enemies to give a sense of urgency
                        world.addEntity(new Pterodactyl((int)world.getLevelWidth(), 0));
                        world.addEntity(new Pterodactyl((int)world.getLevelWidth(), 20));
                        world.addEntity(new Pterodactyl((int)world.getLevelWidth(), 40));
                        world.girlfriend = entity;
                        entity.following = true;
                    }
                }
            }
        }
    }

    public void pickup(Entity pickup) {
        // pick up entity off the ground
        this.currentWeapon = pickup.currentWeapon;
        world.removeEntity(pickup);
        messages.pushMessage("picked up " + currentWeapon.toString());
    }

    public void moveLeft() {
        if (health <= 0) return;
        leftPressed = true;
        if (!rightPressed) dir = direction.LEFT;
    }


    public void stopLeft() {
        leftPressed = false;
        if (rightPressed) dir = direction.RIGHT;
    }

    public void moveRight() {
        if (health <= 0) return;
        rightPressed = true;
        if (!leftPressed) dir = direction.RIGHT;
    }

    public void stopRight() {
        rightPressed = false;
        if (leftPressed) dir = direction.LEFT;
    }

    public void duck() {
        if (health <= 0) return;
        if (!isOnGround()) applyForce(new PVector(0, 3));
        duckPressed = true;
    }

    public void stopDuck() {
        duckPressed = false;
    }

    public void jump() {
        if (health <= 0) return;
        // y - 3 instead of using onground() function so that the dino can jump off slopes
        if (position.y + currentSprite.height > world.getY(position.x) - 3)applyForce(new PVector(0,-jumpSpeed));
    }

    public void draw() {
        if (dir == direction.LEFT) currentSprite.draw(position.x, position.y, true, 1);
        else currentSprite.draw(position.x, position.y, false, 1);

        if (currentWeapon != null) currentWeapon.draw();
    }

    public void shootEquipped() {
        if (health <= 0) return;
        if (currentWeapon != null) {
          if (currentWeapon.shoot())
            // throw player back
                applyForce(new PVector(dir == direction.LEFT? currentWeapon.knockBack : -currentWeapon.knockBack, 0));
          // camera.shake(10);

        }
    }

    public void shoot() {
        shooting = true;
    }

    public void stopShoot() {
        shooting = false;
    }

    boolean isOnGround() {
        return position.y+currentSprite.height >= world.getY(position.x);
    }

}

class Pterodactyl extends Entity {
    Sprite moving;
    Sprite dead;

    float moveSpeed = 3;
    float maxForce = 0.1;
    float gravityAccel = 0.5;

    // track dead
    int deadTimer = 0;
    int deadMax = 100;

    // track attacking
    int attackTimer = 0;
    int attackMax = 30;

    int flyHeight = (int) random(10, 70);


  public Pterodactyl (int x, int y) {
      super(x, y);

      moving = new Sprite("pterodactylMove/pterodactylMove", 2);
      dead = new Sprite("pterodactylMove/pterodactylDead", 1);
      currentSprite = moving;
      alive = true;

      health = 5;

      moveSpeed = random(2, 5);
      maxForce = random(0.05, 0.15);

  }

    void update() {
        // handle death with a counter - once this is up remove entity
        if (health <= 0) {
          currentSprite = dead;
          deadTimer++;

          // fall to the ground
          applyForce(new PVector(0, 0.05));

        }
         // basic logic: seek player if close, otherwise go upwards of player
        // this gives the impression its going for a dive!
        else if (abs(player.position.x - this.position.x) < 200)
            seek(player.position);
        else seek(new PVector(player.position.x, flyHeight));

        // limit y
        if (position.y + currentSprite.height > world.getY(this.position.x)) {
            position.y = world.getY(this.position.x) - currentSprite.height;
            velocity.y = 0;
        }

        // attack player
        int margin = 10;
        
        if (this.health > 0 &&
            this.position.x + currentSprite.width > player.position.x+margin &&
                this.position.x < player.position.x + player.currentSprite.width-margin &&
                this.position.y + currentSprite.height > player.position.y+margin &&
                this.position.y < player.position.y + player.currentSprite.height-margin) {
            if (attackTimer > attackMax) {
                particles.addBlood(player.position.x+player.currentSprite.width/2, player.position.y+player.currentSprite.height/2, new PVector(0,0));
                attackTimer = 0;
                player.health--;
            }
        }
        attackTimer++;

        if (deadTimer > deadMax) alive = false;

        super.update();
    }

    // go towards player
    void seek(PVector target) {
        // http://natureofcode.com/book/chapter-6-autonomous-agents/

        PVector desired = PVector.sub(target, position);

        // scale to max speed
        desired.setMag(moveSpeed);

        // Steering = Desired minus velocity
        PVector steer = PVector.sub(desired,velocity);
        steer.limit(maxForce);  // Limit to maximum steering force

        applyForce(steer);
    }

    void draw() {
        if (velocity.x <= 0) currentSprite.draw(position.x, position.y, true, 1);
        else currentSprite.draw(position.x, position.y, false, 1);
    }


}

class Cactus extends Entity {
      float gravityAccel = 0.5;
      
    // track dead
    int deadTimer = 0;
    int deadMax = 100;
  
    public Cactus(int x, int y) {
        super(x,y);
        currentSprite = new Sprite("cactus/cactus", 6, 0);
        currentSprite.setImage((int)random(0,5));

        health = 10;
    }

    public void update() {
      // apply gravity force
      applyForce(new PVector(0, gravityAccel));

      // apply friction
      PVector friction = new PVector(velocity.x, 0);
      friction.mult(-1);
      friction.normalize();
      friction.mult(Constants.FRICTION_COEFFICIENT);
      applyForce(friction);

      // limit y position
      if (position.y + currentSprite.height - 5> world.getY(this.position.x)) {
          velocity.y = 0;
          position.y = world.getY(position.x) - currentSprite.height + 5;
      }

      if (health <= 0) {
          deadTimer++; 
      }

      if (deadTimer > deadMax) alive=false;
      super.update();
    }

}

class Cloud extends Entity {

    int distance; // how far in the distance the cloud is

    public Cloud(int x, int y) {
        super(x,y);

        distance = (int)random(1, 10);
        currentSprite = new Sprite("cloudFilled", 1, 0);
        health = 1;

        applyForce(new PVector(-random(0.5, 0), 0));
    }
    
    public void update() {
        if (health <= 0) alive=false; 
        super.update();
    }

}


// special pterodactyl to help carry away dinosaurs girlfriend
class PterodactylEscort extends Pterodactyl {
    GirlfriendPterodactyl target;

    public PterodactylEscort(int x, int y, GirlfriendPterodactyl target) {
        super(x, y);
        this.target = target;
    }

    void update() {
        seek(target.position);//.add(new PVector (10, random(-10, 10))));

        if (deadTimer > deadMax) alive = false;

        // TODO refactor this into generic pterodactyl class, and have attacker pterodactyl subclass
        velocity.add(accel);
        position.add(velocity);
        accel.mult(0);

        if (position.x > world.getLevelWidth()) alive = false;

    }
}

// special pterodactyl that carries the girlfriend away
class GirlfriendPterodactyl extends Pterodactyl {

    public GirlfriendPterodactyl(int x, int y){
        super(x, y);
        currentSprite = new Sprite("pterodactylCarry/girlfriendPterodactyl", 2);
        health = 100;
        moveSpeed = 2.5;
        maxForce = 0.2;
    }

    void update() {
        seek(new PVector(world.getLevelWidth(), -80));

        if (deadTimer > deadMax) alive = false;

        velocity.add(accel);
        position.add(velocity);
        accel.mult(0);

        // kill if outside the screen
        if (position.x > world.getLevelWidth()) alive = false;
        if (position.y < -50) alive = false;
    }
}

class GirlfriendDino extends Entity {
    Sprite idle;
    Sprite moving;

    float moveSpeed = 3;
    float maxForce = 0.1;
    float maxMoveSpeed = 4;
    float gravityAccel = 0.5;

    direction dir;

    public GirlfriendDino (int x, int y) {
        super(x, y);
        idle = new Sprite("pinkDinosaur", 1);
        moving = new Sprite("dinoMove/pinkDinosaurMove", 2);
        dir = direction.LEFT;
        health = 10;

        following = false;
        currentSprite = idle;
    }

    public void update() {
        // apply gravity
        applyForce(new PVector(0, gravityAccel));

        // limit y position
        if (isOnGround()) {
            velocity.y = 0;
            position.y = world.getY(position.x) - currentSprite.height;
        }

        seek(player.position);

        // update moving sprite
        if (following) currentSprite = moving;

        // check if the game has finished.
        if (world.levelManager.currentLevel == 0 &&
            world.gameOver == false &&
            this.position.x < world.getLevelWidth() - 300) {
            world.gameOver = true;
            messages.pushMessage("You saved the princess!");
        }
        super.update();
    }

    void seek(PVector player) {
        if (!following) return;

        // head towards player coordinates using same method as pterodactyls.
        PVector desired = PVector.sub(new PVector(player.x, world.getY(player.x)-40), position);
        desired.setMag(moveSpeed);

        // steering = desired - velocity
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxForce);

        applyForce(steer);
    }

    void draw() {
        if (velocity.x <= -1) currentSprite.draw(position.x, position.y, true, 1);
        else currentSprite.draw(position.x, position.y, false, 1);
    }

    boolean isOnGround() {
        return position.y+currentSprite.height >= world.getY(position.x);
    }
}

