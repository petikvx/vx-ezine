; ������������������������������������������������������������������������������
;               Exit

closewsa:       invoke  WSACleanup
freeexit:       invoke  LocalFree, ebp
exit:           ret