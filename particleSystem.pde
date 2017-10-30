// Particle system for entire game
// with reference to:
// Nature of Code (Daniel Shiffman)


class ParticleSystem {
    private ArrayList<Particle> particles;

    public ParticleSystem() {
        particles = new ArrayList();
    }

    void addBlood(float x, float y, PVector force) {
        particles.add(new Blood(new PVector(x, y), force));
    }
    
    void addCactiParticle(float x, float y, PVector force) {
        particles.add(new CactiParticle(new PVector(x, y), force));
    }

    void addTrail(float x, float y, PVector force) {
        particles.add(new TrailParticle(new PVector(x, y), force));
    }

    void update() {
        for (int i = particles.size()-1; i >= 0; i--) {
            Particle p = particles.get(i);
            p.update();
            p.draw();
            if (p.isDead()) {
                particles.remove(i);
            }
        }
    }
}

class Particle {
    PVector position;
    PVector velocity;
    PVector accel;
    float lifespan;

    Particle(PVector l,PVector dir) {
        accel = dir.get();
        velocity = PVector.random2D();
        position = l.get();
        lifespan = 255.0;
    }

    // Method to update position
    void update() {
        velocity.add(accel);
        position.add(velocity);
        lifespan -= 2.0;
    }

    // Method to display
    void draw() {
        fill(127,0,0,lifespan);
        ellipse(position.x,position.y,12,12);
    }

    // Is the particle still useful?
    boolean isDead() {
        if (lifespan < 0.0) {
            return true;
        } else {
            return false;
        }
    }
}

// blood is a red, slightly larger particle
class Blood extends Particle {
    int size = (int) random(2,5);
    
    Blood(PVector l, PVector dir) {
        super(l, dir);
        lifespan = 100;
        accel= new PVector (0, 0.05);
    }

    void draw() {
        noStroke();
        fill(random(200, 255), 0, 0);
        ellipse(position.x, position.y, size, size);
        stroke(0);
    }
}

// cacti particles are created when a bullet hits a cacti, smaller green particles
class CactiParticle extends Particle {
  int size = (int) random(1,4);
    
    CactiParticle(PVector l, PVector dir) {
        super(l, dir);
        lifespan = 100;
        accel= new PVector (0, 0.05);
    }

    void draw() {
        noStroke();
        fill(0, (int) random(150, 255), 0);
        ellipse(position.x, position.y, size, size);
        stroke(0);
    }
}

// subtle dirt/sand getting kicked up by the dino
class TrailParticle extends Particle {
    int size = (int) random(1,3);
    
    TrailParticle(PVector l, PVector dir) {
        super(l, dir);
        lifespan = 10;
        accel= new PVector (0, 0.005);
    }

    void draw() {
        noStroke();
        fill(0);
        ellipse(position.x, position.y, size, size);
        stroke(0);
    }
}
