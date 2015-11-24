#include "general.h"
#include <stdio.h>
#include <or1k-support.h>

void exception_occured_0(void)
{
        printf("Exception occured at 0x000\r\n");
}

void exception_occured_1(void)
{
        printf("Exception occured at 0x100, Reset exception\r\n");
}

void exception_occured_2(void)
{
        printf("Exception occured at 0x200: Bus error\r\n");
}

void exception_occured_3(void)
{
        printf("Exception occured at 0x300\r\n");
}

void exception_occured_4(void)
{
        printf("Exception occured at 0x400\r\n");
}

void exception_occured_5(void)
{
        printf("Exception occured at 0x500\r\n");
}


void exception_occured_6(void)
{
        printf("Exception occured at 0x600\r\n");
}


void exception_occured_7(void)
{
        printf("Exception occured at 0x700\r\n");
}


void exception_occured_8(void)
{
        printf("Exception occured at 0x800\r\n");
}


void exception_occured_9(void)
{
        printf("Exception occured at 0x900\r\n");
}


void register_exceptions(void)
{
   or1k_exception_handler_add(0, exception_occured_0); 
   or1k_exception_handler_add(1, exception_occured_1);
   or1k_exception_handler_add(2, exception_occured_2); 
   or1k_exception_handler_add(3, exception_occured_3);
   or1k_exception_handler_add(4, exception_occured_4); 
   or1k_exception_handler_add(5, exception_occured_5);
   or1k_exception_handler_add(6, exception_occured_6); 
   or1k_exception_handler_add(7, exception_occured_7);
   or1k_exception_handler_add(8, exception_occured_9); 
   or1k_exception_handler_add(9, exception_occured_8);
}