import java.util.Queue;
import java.util.ArrayDeque;


class MessageSystem {

    // private Queue<Message> messages;
    private ArrayList<Message> messages;
    private Queue<Message> delayedMessages;

    private int time;

    private int x = width/2;
    private int y = 30;
    private color textColor = color(100, 100, 100);

    public MessageSystem() {
        messages = new ArrayList();
        delayedMessages = new ArrayDeque();
        time = 0;
    }

    void pushMessage(String message, int length, messageType type) {
        messages.add(new Message(message, length, type, 0));
    }

    void pushMessage(String message) {
        pushMessage(message, 300, messageType.NORMAL);
    }

    void pushDelayedMessage(String message, int delay, int length, messageType type) {
        delayedMessages.offer(new Message(message, length, type, delay));
    }

    void pushDelayedMessage(String message, int delay) {
        pushDelayedMessage(message, delay, 300, messageType.NORMAL);
    }

    void draw() {
        textAlign(CENTER);
        fill(textColor);


        // iterate through first three messages in arraylist
        int msg=0;
        while (msg < 3) {
            Message current;
            if (msg < messages.size()){
                // remove if dead, otherwise draw
                current = messages.get(msg);
                if (!current.isAlive()) {
                    messages.remove(current);
                    continue; }
                current.draw(x, y+msg*20);

            }
            msg++;
        }



        // if first message on delay queue is ready, add it to usual queue
        if (delayedMessages.size() > 0) {
            time++;

            if (time > delayedMessages.peek().delay) {
                println(delayedMessages.peek().delay);
                time = 0;
                messages.add(delayedMessages.poll());
            }
        }
    }

}

class Message {
    String message;
    int length;
    messageType type;
    int delay;

    private int aliveTime;
    private int opacity;
    private boolean alive;

    public Message(String message, int length, messageType type, int delay) {
        this.message = message;
        this.length = length;
        this.type = type;
        this.delay = delay;

        aliveTime = 0;
        opacity = 255;
    }

    public void draw(int x, int y) {
        aliveTime++;

        // decrease opacity if over time
        if (aliveTime > length && opacity > 1) opacity--;

        // draw
        textAlign(CENTER);
        fill(getColor());
        text(message, x, y);
    }

    public color getColor() {
        // get the colour based on the type of the message
        color current;
        switch (type) {
        case NORMAL: current = color(0, 0, 0, opacity); break;
        case URGENT: current = color(255, 0, 0, opacity); break;
        default: current = color(0, 0, 255, opacity); break;
        }

        return current;
    }
    public boolean isAlive() {
        return this.opacity > 1;
    }
}
