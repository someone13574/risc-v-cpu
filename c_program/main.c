int test_function(int a, int b)
{
    return a + b;
}

void __attribute__((naked, section(".entry"))) _start(void)
{
    int* ptr = (int*)0x1000;
    *ptr = test_function(-6, 5);
}
