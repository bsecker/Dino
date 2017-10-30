/* Handle weapons in the game, including pickups, bullets and behaviours*/
// pistol, machinegun, grenade launcher, sniper


class EquippedWeapon {
    PVector position;
    Sprite weaponSprite;
    direction dir;
    int knockBack; 

    WeaponPickup pickup;

    public EquippedWeapon(int x, int y, direction dir) {
        position = new PVector(x, y);
        this.dir = dir;
    }

    public EquippedWeapon(int x, int y) {
        this(x, y, direction.RIGHT);
    }

    void draw() {
        if (weaponSprite == null) {
            ellipse(position.x, position.y, 5, 5);
        }
        else {
            if (dir == direction.LEFT) weaponSprite.draw(position.x, position.y, true);
                else weaponSprite.draw(position.x, position.y, false);
        }
    }

    // update position and direction
    void update(PVector position, direction dir) {
        this.position = position;
        this.dir = dir;
    }

    // return true if shot
    boolean shoot() {
      return false;
    }
    
    String toString() {
     return "weapon!";
    }
}

class Pistol extends EquippedWeapon {
    int ammo;
    int reloadTime = 20;
    int reload;

    public Pistol(int x, int y) {
        super(x, y);
        ammo = 100;
        reload = 0;

        weaponSprite = new Sprite("weapon/pistolPickup", 1, 0);
        knockBack = 4;
    }

    boolean shoot() {
        if (reload > reloadTime) {
            reload = 0;

            // shoot
            if (dir == direction.RIGHT) world.addBullet(new Bullet((int)position.x, (int)position.y, 0, 10));
            else world.addBullet(new Bullet((int)position.x, (int)position.y, PI, 10));

            return true;
        }
        return false;
    }

    void update(PVector position, direction dir) {
        super.update(position, dir);
        reload++;
    }
    
    String toString() {
      return "pistol";
    }
}

class MachineGun extends EquippedWeapon {
    int ammo;
    int reloadTime = 5;
    int reload;

    public MachineGun(int x, int y) {

        super(x, y);
        ammo = 100;
        reload = 0;

        weaponSprite = new Sprite("weapon/machineGunPickup", 1, 0);
        knockBack = 3;
    }

    boolean shoot() {
        if (reload > reloadTime) {
            reload = 0;
            
            // shoot
            if (dir == direction.RIGHT) world.addBullet(new Bullet((int)position.x, (int)position.y, 0+random(-0.05, 0.05), 10));
            else world.addBullet(new Bullet((int)position.x, (int)position.y, PI+random(-0.05,0.05), 10));

            return true;
        }
        return false;
    }

    void update(PVector position, direction dir) {
        super.update(position, dir);
        reload++;
    }
    
    String toString() {return "machinegun";}
}

class Shotgun extends EquippedWeapon {
    int ammo;
    int reloadTime = 30;
    int reload;
    public Shotgun(int x, int y) {
        super(x, y);
        ammo = 100;
        reload = 0;
        weaponSprite = new Sprite("weapon/shotgunPickup", 1, 0);
        knockBack = 6;

    }
    boolean shoot() {
        if (reload > reloadTime) {
            reload = 0;

            // shoot
            if (dir == direction.RIGHT) for (int i=0; i<3; i++) world.addBullet(new Bullet((int)position.x, (int)position.y, 0+random(-0.1, 0.1), 10));
            else for (int i=0; i<3; i++) world.addBullet(new Bullet((int)position.x, (int)position.y, PI+random(-0.1,0.1), 10));


            return true;
        }
        return false;
    }

    void update(PVector position, direction dir) {
        super.update(position, dir); //<>//
        reload++;
    }
    
    String toString() {return "shotgun";}
}



// ***********************************************************

class Bullet {
    PVector position;
    PVector velocity;
    Sprite currentSprite;

    boolean alive;

    public Bullet(int x, int y, float dir, int vel) {
        position = new PVector(x, y);
        velocity = new PVector(cos(dir) * vel, sin(dir) * vel);

        alive = true;
    }

    void draw() {
        ellipse(position.x, position.y, 3,3);
    }

    void update() {
        position.add(velocity);

        // destroy if intersect with ground or outside level
        if (position.x < 0
            || position.x > world.getLevelWidth()
            || position.y > world.getY(position.x)) alive = false;
    }

    void checkCollision(ArrayList<Entity> collideWith) {

        // check every entity in collideWith if there is a collision, and apply relevant effects depending on what it hits.
        for (Entity collide: collideWith) {
            if (this.position.x > collide.position.x &&
                this.position.x < collide.position.x + collide.currentSprite.width &&
                this.position.y > collide.position.y &&
                this.position.y < collide.position.y + collide.currentSprite.height) {

                // collide with pterodactyl makes blood effect and damages enemy
                if (collide instanceof Pterodactyl){
                    this.alive = false;
                    collide.health --;
                    PVector hitForce = velocity.get().mult(0.1);
                    collide.applyForce(hitForce.copy().mult(2));
                    int bloodParticles = (int) random(1,4);
                    for (int i=0; i< bloodParticles; i++) particles.addBlood(position.x, position.y, hitForce);
                    
                }

                // collide with cactus makes cactus effect and damages cactus
                else if (collide instanceof Cactus) {
                    this.alive = false;
                    collide.health --;
                    
                    PVector hitForce = velocity.get().mult(0.4);
                    // fling cacti back
                    if (collide.health <= 0) {
                        collide.applyForce(hitForce);
                    }
                    particles.addCactiParticle(position.x, position.y, hitForce);
                    // particles.addParticle(position.x, position.y, hitForce);

                }
            }
        }
    }

}



// ***********************************************************
// weapon pickups extend entity as they are a physical object that can be interacted with in the game world.

class WeaponPickup extends Entity {

    public WeaponPickup(int x, int y) {
        super(x, y);
        position = new PVector(x, y);
    }

    void draw() {
      if (currentSprite != null) {
        currentSprite.draw(position.x, position.y);
      }
    }

    void update() {
        // update y position to be above ground at all times
        if (this.position.y + this.currentSprite.height > world.getY(this.position.x)) this.position.y = world.getY(this.position.x) - this.currentSprite.height;
    }
}

// pickup objects hold a weapon object that the player uses.

class PistolPickup extends WeaponPickup{
  public PistolPickup(int x,int y) {
    super(x,y);
    currentSprite = new Sprite("weapon/pistolPickup", 1, 0);
    currentWeapon = new Pistol((int) position.x, (int) position.y);
    currentWeapon.pickup = this;
  }

}

class MachineGunPickup extends WeaponPickup {
    public MachineGunPickup(int x, int y) {
        super(x, y);
        currentSprite = new Sprite("weapon/machineGunPickup", 1, 0);
        currentWeapon = new MachineGun((int) position.x, (int) position.y);
        currentWeapon.pickup = this;
    }
}

class ShotgunPickup extends WeaponPickup {
    public ShotgunPickup (int x, int y) {
        super(x, y);
        currentSprite = new Sprite("weapon/shotgunPickup", 1, 0);
        currentWeapon = new Shotgun((int) position.x, (int) position.y);
    }
}
