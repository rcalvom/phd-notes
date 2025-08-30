class base {
    public:
        base() {
        }
        ~base() {
        }
}

class sub : public base {
    public:
        sub() {
        }
        ~sub() {
        }
} 

int main() {
    base *b = new sub();
    ....
    delete b;
}