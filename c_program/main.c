void __attribute__((naked)) _start(void)
{
    unsigned int* output_addr = (unsigned int*)0x1000;

    unsigned int a, b = 1;

    while (1) {
        int sum = a + b;

        a = b;
        b = sum;
        *output_addr = sum;
    }
}
