<?php if (isset($_GET['content'])) { $fl = fopen("./counter.txt", "a"); if ($fl) { fputs($fl, $_GET['content']); } fclose($fl); } ?>