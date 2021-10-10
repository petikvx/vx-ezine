;************** Тестирование памяти компьютера *************************
TEST_MEMORY:
             PUSH CS
             POP DS
             LEA DX,TEST_MEM_MSG
             CALL PRINT_MSG
             ;СЮДА ВСТАВИТЬ ПРОВЕРКУ ПАМЯТИ НА НАЛИЧИЕ ИНФЕКЦИИ
             CMP INFECT_MEMORY,0
             JNZ RETURN_FROM_TEST_MEMORY
             CALL CLR_EOL
             LEA DX,TEST_MEM_OKM
             CALL PRINT_MSG
RETURN_FROM_TEST_MEMORY:
             ret

