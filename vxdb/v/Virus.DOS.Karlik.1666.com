�i 
If I were looking at the internals of this
program, I would pay special attention to the
bits in the byte at 103 (4th byte of file).  The
byte at 104 isn't interesting to you because you
need different video hardware for those options
to work properly.  Note: Its very easy to patch a
.COM file using debug.

   bit 0 - Allow Auto Switch State
   bit 1 - Allow EGA Locked State
   bit 2 - Allow Fast Mode
   bit 3 - Enable Panel Options
   bit 4 - Enable Menu Driven Mode
   bit 5 - Use the AT&T Menu
   bit 6 - Reserved
   bit 7 - Reserved


p.s. If you are having a hard time reading this, try
the DOS TYPE command.
���?����Î؎���� �J�!�؎���.�� �5��!���* �( �%��L�!������>~*�ߍ6# � 󤾀 �ڌȎج��ȸ  �:t�󤪎ډ> ��+�O�3��
�UuBRC�	�t�e�����PS���* �( �ش%��!XX�>' u�' �L�!�.��?PR�����ZXύ P�X�L�!VU���3�� @ t�� u�F�	����F��1�F������F��F t%�F�t�(�~� tK�~�@u�3(�@�~� u:�d(�5�F t.�F�t��(�~� u��(��~�@t�~�u�)�	�~�u�U)�Ƌ�]^�VWU��LL3�� @ t�
� u�	 ��6����F��~@u2� t��#�F� t
�F
 t�@$��u��#� ��t� ��#� �~ u�F� t�@$�t�m �n$�g �~`u+�F� t	�uV��$�Q�F� tJ��u�8%�@��u;��%�6�~ t�~� u)�F� t	�u�Z&��F� t��u��&���u�p'�Ƌ�]_^�U��F2��]�U��@ ���^&�� �����^&�J ��^
&�� �3�&�� t&�>I t	&�>I rC� �� P��P���$t<tm<u���taC�^���tVCC�R� P��P�_��tAC� P&�c P�L��u�u*C�'��� P��P�1��@tC� P��P���uC��]�VWU��LL�~
�F�F��~ u�, ��~u�5 ��> � PP�v�W��FP�V*�W��
�F��P� PF��F�PW��FP�V*�W��
� PP�FFHPW��FP�V*�W��
� P�F��P�FFHPG��P��FP�V*�W��
� PP�FFHP�F
FHP��FP�V*�W��
�F��P� P�v��F
FHP��FP�V*�W��
� PP�v�F
FHP��FP�V*�W��
� P�F��P�vWV�V*�W��
��]_^���VU����F�v�F�F�F�F �2��v
�V ��
�2��� ��F �Nu��F
�Nũ�]^��WU����~�F�F�F�F �2��v
�V ��2����F �Nu��F
�Nuу�]_��SVU����v�F�F�F�F �2��v
�V ���ܴ	2�� ��F �Nu��F
�Nũ�]^��U��2��v�V��
�^�2���N��F�N
u�]���
U�� �~�n�N�v
��ΊV����]��
U����F�F�F
�F �2��v�V ��2���	2��^� ��F �Nu��F�Nuƃ�]��t
VWU����F�F�&L*�&\*F���F�&L*�F 3ێ��� ������ � ����W�v�NV6�6�&L*��� �^F��_6>\*C�N uۃ�]_^���	VWU��F�&L*�&\*F���F�&L*�؋~
� ��غ�� ���VSV�N�^&6\*Ku�[^��y�]_^��	VWU��F�&L*�&\*F���F�&L*�؋v
� ������ � �����WSW�N�_>\*Ku�[_��u�]_^��S	VWU��F�&L*�&\*F���L*����^�'3ێ��ظ ������ � ����W��N�_6>\*CNu�6�6L*+��Nu�]_^���VWU��F�&L*�&\*F���F�&L*�ظ ������ � ������WS�F
W�N�_>\*Ku�[_�����u�]_^��VWU��F�&L*�&\*F���F�&L*�ظ ��؎���� �����W�N��Ī��_6>\*Ku�]_^ð4�C2��@�@ð6�C2��@�@��2��C�@���@��3�+�3��ءl���WU��3��؋N�l;lt���]_�U���v� ����
�V� �@�!]�WU���~3Ɋ�I����H]_�VWU���v
�����@�ȋ~�v
��H]_^�VWU��v�~
�
�t�t�*E��]_^�U���v����F�vP����]�VU���
� P��P�a��% �����F��~�u� ���~�u� ��� ��� P��P�0���F�� P��P����F�� P��P����F��F�� %��P� P��P����F��  P� P��P����F��  P�� P��P�� ��V� DD�F��F�� %��P�� P��P�� ��V�k DD�F��F�� P� P��P� ���F�� P� P��P� ���F�� P�� P��P� ���d �f��v��F��F�;F�v�~�� r� �� � ��]^�VU�����������V��F�V�F�ع 3��^����+F�V��V��F�����F���]^�U���F�0���$<t<w2��]�U��V�F�f�]�U�� ���;�F��F ��$��f����F u#�F u<t<t

�t�F t
��0����� � �	<t��w�2���r
�t<r��F u���@ �؀& �> �&� �.� �&� �� �&� �6� 2����� ]�U��2��n�N�]�U��2��v�V�]�VU��6 �>  t� F; s�F ������]^ø@ ���r 4���P3�P�U���������B�J�ĉF����B�J�ĉF �@ �؋c ���t��u��ĸ ︯ � 2���İ����t�À�����F�F � ��2��]�U������F�İ����B��ʆ��F���Fu���t��u��ĸ�� � 2������� �t�À���F�ċF� ��% ��]Á& ��� ���< u3��o<u'�  �& ��& ��& ��& ߃& ��& ��A<u� H��t��& ���@t� �Āt� H�   t� �& ��& �� �U�����2�
�t�F�^��� ]�U����� �������u� �3�]�U����� ������� u� �3�]ô���P}���u� �� ��VWU��LL�F %���F�����P���DD�����u3�����F��E�� P��DD�� ��]_^�VU���v��������t����H P�w��� P���]^�U���v���]�2��ú����u����B����PR2��J�B�������ϋ��B�
�u��J���B�<u��2��3�ZJX���U��V�F�B�2�]�U��2��2�^�/�g�^��g]ú��% 5 ø ���
�u2�ø ����3��ػ���� �Àu����u�^ô� ���� �� P��P�v���% �;��%� ���P����� ����@ �ػ� �t��2�X�����V�.�2�ø� P��P�%������2�à.2���@ �ظ �� t3�ô�!
�u��!��2�ø D� �!3���u��UV��v3�� t	�<
u@F��^]�VWU��~����6� ��;�w
;�w�;�w�4;�v�;�v�E�����;u��GE�������D�����;�u�ED����<�6� ]_^�VWU����~
�F� �F3���������V+ЉV��tWV������^���l �F��F�P��DD��]_^�U��F�^
�NȋV�=  }3�;H*~�H*�� }3�;R*~�R*+�~+�~�F��+F
�^
�N�V]�]��ú��P�� P��P����P����ﲴ�" u�.��� u�.X���య�X����2���t��R���$�
Ĳ��Z� PR�V���JP�:�2�PR�F���J�ظ PR�c�����:�VWU�� ��ؾ���/:Du:Du�~
� �2��]_^�VW� �������6~ �� +��t3��� _^�U�� ���
�t���������^�'2�g�^�]�VWU��LL�F ����F��>� ���u�D*�ǣ� �D*�F*  �5�D;F�|.�D;F�u����F�)D�D������F��D�>� �� � ;6� u�v��q�DD�����u3�����4몋�]_^�VWU�����t
3�P�O�DD�	� P�D�DD�u�$�F�P�F�P�����Z*  �f�\� P�v�����J*�F��{��F�� t�f�� �F�= Ht%= u� = u��= GtT��= Ot_= Pt뽡J*;T*~
�J*�Z*�R�   uJ�;�J*;P*}
�J*�Z*�"�   u�T*�J*�Z*  ��Z*  �T*�J*��w�b*H�Z*�P*�J*���d�v��v��	���3�P�H*HP������P�Z*� ���r*�w�R����u�8�Z*� ���r*�w�DD�F��F�P�F�P������d*P�Z*� ���r*�w�	����t�:
P�Z*� ���r*�w�����uR�Z*� ���r*�w�F�P������Z*  �#�Z*� ���r*�w�F�P����t�Z*�Z*;b*|Ը P��P�-���� t� P�v����3�P�v�� ���~� t�Z*� ���r*�G
Z*�T*�J*3��>r*��}	 t�J*F��;6Z*|�T*�F��6J*�v��������v��v�������"�v�DD�v�DD3�P���DD��]_^�U��Z*� ���r*�	 u&�b*H;Z*~�Z*���   u�Z*  ������ ]�U��Z*� ���r*�	 u$�>Z* t�Z*���   u�b*H�Z*�������]�VWU���
��L*P�R*P�H*P���= u�V*%�R*�\*��V*�6R*�6H*3�PP�V*�G� P�W��
�6R*�6H*3�PP� P���
�F�P�F�P�����F���0�l�F��
 �����0�n�F��������V�*Ѐ�0�o�v��DDP�6`*�|�DDZ�R�5P�o�DDZ�BR��DD�F��5P�6`*�v�v��g��P�`��P�Y��� P�v����� P�:P����v���DD�   t�N*  �^*  ���P���DD�N*�rP���DD�^*�6r*3��>T*�6�|	 t�t���DD�X*;N*~�N*�T*�t��DD�F�;^*~�^*G��;>b*|ă^*�^*N*�R*+N*���X*�   t� �T*�J*�t� �T*�J*�rP�j�DDP� P�6X*�T*HP�rP�V*���
��P�F�DDP� P�X*^*P�T*HP��P�V*���
�6N*� P�6X*�T*HP� P�V*�W��
�T*�P*3��6r*� �|	 t+�t���DDP� P�X*^*P�6P*�t�V*���
�P*�N�|
 }'�t��DDP� P�6X*�D
P*P�t�V*���
�!�t��DDP� P�6X*�6P*�t�V*���
G��;>b*}�t��P*�   tS�N*+^* P�P*+T*@P�X*^*HP�6T*�V*�G� P�W��
�H*��P��P����H*��P��P����3�P�  P�����   t�V*�G� � �F���V*�G� �F��~
 t)�N*+^* P� P�X*^*HP�6J*�v��V*�W��
��]_^�VWU������F���� ���F��6r*3��A�| t�T�D	�/�| t%�|u�F��F���F��F��D"F�:Du�D	 ��D	G��;>b*|���]_^�VWU���   t�V*�G� ���G� ���π ��V*�G� ���G� ���N*+^* P� P�X*^*HP�vV�V*�W��N*+^* P� P�X*^*HP�v
W�V*�W��]_^�VWU����0%�   t�0%�� �� ��0�  u��   �  u�� ��  t��� u� �3��   u�V�b*  �>r*�>�ƺ ��؃�� t� P�ƺ ���X���u��ƺ ��؋����ƺ ��؋���E�ƺ ��؋���E�ƺ ��؊���E�ƺ ��؊���E�ƺ ��؊���E�ƺ ��؊���E	�ƺ ��؋���E
�ƺ ��؋���E�ƺ ��؋���E�ƺ ��؊���E�ƺ ��؊���E�ƺ ��؊���E�ƺ ��؋���E�ƺ ��؋���E�ƺ ��؊���E�ƺ ��؋���E���b*F��s������ ��% �F���F��b*  �>r*��~� u� �~� u� �ƺ ��؀�U t��ƺ ��؃�> t� P�ƺ ���X��>u�]�  u�< �:
P�ƺ �����@����u�4�d*P�ƺ �����@����u��ƺ ��؋�>��ƺ ��؋�@�E�ƺ ��؋�B�E�ƺ ��؊�D�E�ƺ ��؊�E�E�ƺ ��؊�F�E�ƺ ��؊�G�E	�ƺ ��؋�H�E
�ƺ ��؋�J�E�ƺ ��؋�L�E�ƺ ��؊�N�E�ƺ ��؊�O�E�ƺ ��؊�P�E�ƺ ��؋�Q�E�ƺ ��؋�S�E�ƺ ��؊�U�E�ƺ ��؋�V�E���b*F��#s�N���]_^�VU���v����V� P�R*+���P�v�v�V*���]^�U�츯 P��P����% ]�U�����=� t���= t3��� ]�U�����=^t���= t3��� ]�U�����=�t��= t3��� ]�U�����u� �3�]�VU��~u"� @ t�� P��P�3���% = u�' � P�	���v�� P�������]^�VU���v������u��P�����P�����k��3����]^�VU���v�����u��P�����P����9��3����]^�VWU����~
���t�3 ��3 ����� P���DD�r*�I�F�P�DD�j*�   t�`*\��`*:�%P��DD����u-�6j*�DD�|P��DD�6j*��DD��P��DD� P�]�DD�=��u-�6j*��DD�|P�DD��P�DD��P�DD� P�)�DD�  t�  �& ��� @ t� � �  tp� @ uh��� �����F��~� t�F� ��F��F�� P�� P�4���� ��% �V�� ;�u� � �~� t�F� ��F��F�� P�� P������P�d*P�q����P�l*P�c����P�t*P�U���  t:� @ u2� � u*��P�d*P�/����P�l*P�!����P�t*P����d*P�P�?���d*P��P�1��� P��P�#���  u����� u� P�� P�F���C����  t�~�6j*�I�DD3�P��DD� �l�����?-t`�����?/tU�����1�DD�P�����1����t�P�����1�{���u"�^K���F������^K���F�����F�FH;���6j*��DD� �������?-t�����?/t�� �������? u�������   =c u�!�׋�����   =d u%�P�;DD�%P�2DD�}P�)DD3�P��DD�q������   =s u�"��������   =v u�#�l�������   =h t(�����??t�}P��DD�����1�DD�)P�DD�$�����1�DD�����1��DD= }(�}P�DD�����1�DD�GP�vDD�P�mDD�0�����1�aDD= t� �}P�ODD�����1�DDD��P�;DD��P�2DD��P�)DD�6j*� DD��P�DD�  t=�P�DD�(P��DD���%� �F��}P��DD�~�t�6j*���DD3�P�j�DD�	� P�_�DDF;v}�(��>" u�># t	�6j*�gDD�v���DD�6j*��DD3�P�&�DD��]_^�VWU��}P�|DD�DP�sDD�6j*�jDD�OP�aDD�  t��� t;�ZP�HDD3��6r*��|u�t�2DD�'P�)DD��G;>b*|߸P�DD3��6r*��\�? t�t��DD��G;>b*|�}P��DD�^P��DD�uP��DD��P��DD��P��DD�P�DD�  t�B� tK�GP�DD3��6r*�4�|u*�aP�DD�t�DD�t�\DD�t�vDD��P�mDD��G;>b*|ƸeP�ZDD3��6r*�K�}P�t�����t6�|t�|u*�aP�,DD�t�$DD�t��DD�t�DD��P�DD��G;>b*|�� P��DD]_^�VU��v��<ar�<zw�$�F�< u�]^�U���v�����6`*����5P���}P���:P��市P���]�VWU����v���DD�F��~���N�O�~� t�=.u����<\t�<:tN;vs���+�P��DD�F��F�F���^��F�F�;�r�^�� �F���]_^�U�츇P�!DD�f鸫P�DD��P�DD��P�DD]�VWU��LL3��~��6r*� �t�v����t� �  t�d*P�t�k���u��u3�� �| t�D� P�D� P������tU�| t�t�TDD���tA�>$ u:�t�u DD�|u#�t��P����u	��P�U DD��P�L DD��P�C DD������F��F�;b*}�?�� ��]_^�VU���v�����
�'P� ��F��|�]^�VWU����v�_�DD�F�� �F��F�� ���v��<u
3��1�F���<
u�F���F�GF;~�r݊F�� 1�>1Nv�F��F�� �1�}P���DD�F�� /�v���DD�/;3v3��P���DD�縫P��DD��P��DD��P��DD�/  �1  ��]_^�VWU����F�  �����F������U��0��]���ش���F������ �7�Q��i�����V�/�1  �=P���DD�F��ػ ��������t2����^����  t)�- P�p P�����F� �� ������ ��DD� ��D��
�u���2��V�~� u4�F� �-� @ u�  t2�� P��P���% �F��u�F� �F� ������ �,�DD�[�� P��P�h���F�%��P�� P��P�~���� ��F��u�F� �F� ������ ���DD�v��� P��P�F���XP���DD�   t7�\P��DD�� P��P����� ��� ������ ��DD�uP��DD�	�\P�~�DD�
�%� � ��� ������ �c�DD�XP�Z�DD��P�Q�DD���2�F��F� t��P�8�DD�	��P�-�DD��P�$�DD�  u���F�YP�
�DD�F� t��P���DD� �"� t�F� u��P���DD�P���DD�n���� t�F� u��P��DD�,P��DD�J��= u�F� u;��P��DD�LP��DD�'�� P��P����� t�wP�q�DD�	��P�f�DD�XP�]�DD��P�T�DD�F� t��P�D�DD�	��P�9�DD�XP�0�DD�P�'�DD�F� @t�8P��DD�	�WP��DD�XP��DD�  u���F�YP���DD3��9� @ u�������〿F u��F� t�������〿G t��  t��P����������@�8݃��u�� ����������@�{�DD��������΃��F���% �����B�Y�DD� @ u� ��t� �q� t�F� u�uP�.�DD�P�%�DD�n��M� t�F� u�uP�
�DD�,P��DD�J���= u�F� u;�uP���DD�LP���DD�'�� P��P���� t��P���DD�	��P��DD�XP��DDF��}��� @ tQ�F� uJ��P��DD�^�������x�z�DD�XP�q�DD�P�h�DD�^�������������S�DD�XP�J�DD�># u���YP�7�DD�P�.�DD�8P�%�DD�~� �u�mP��DD�	�sP�
�DD�XP��DD�  t%�yP���DD� P�� P��P�*��P����� �R�% �F��t�F�  ��F� � @ t�F�b��F����P��DD�
 P�v������P��DD� P�� P��P�����P�h���XP�f�DD�F�
��P�Y�DD�
 P�v��E����P�C�DD� P�� P��P�}���P�#���XP�!�DD���F��t� t	��P�	�DD�P� �DD�+�F� t�P���DD�CP���DD�$�F� t�LP���DD�nP���DD�	��P��DD�  t.�����F�P��DD�
 P�F� ��P�����P��DD� @ t4��P�v�DD�t*P�m�DD��P�d�DD�z���������T�DD�XP�K�DD�~� �u��D�����V��P�/�DD�}�� P�#�DD� @ u�  t&�� P��P�Q߃�������% �F�= uD�F� �=�� P��P�+߃��F�%��P�� P��P�Aۃ��X�% �F��v��� P��P�'ۃ��^�����,��DD�8 P��DD�>! tU3��L�D P��DD�������׹ ���P�8DD�D P�g�DD�� �����׃�� ���P�DD�YP�C�DDG��r��� P��P�{ރ�=� �  u9�I P��DD�[ P��DD�� P��P�Nރ��؃��������DD�XP���DD�  uJ���%� �F�= t<�t8�� P��P�ރ�=� %�w P��DD�ۋ؃��������DD�XP��DD�� P��DD�� P��DD�%P�|�DD�YP�s�DD�|*P�z*P������� P�\�DD�
 P�6z*�G߃��� P�E�DD�
 P�6|*�0߃��XP�.�DD�D P�%�DD�v��DD�� P��DD�5P��DD�XP��DD�� P���DD�8��u	�!P���DD�!P���DD�*!P���DD�<!P���DD��2�F��~�v	�~�t�� �@ �ؠ� 2�F��F� t�v���DD�W!P��DD�� �@ �ؠ� 2�F��F� t0�~�s�s!P�g�DD�� �~�t�x!P�U�DD� �}!P�I�DD� �~�u��!P�7�DD� �@ �ؠ� 2�$�F��~�t�~�	u�
 P�v��ރ���!P��DD�c��
 P�v���݃��S��~�t�~�u0�@ �ؠ� 2�$�F�� P�v��݃��F�` t!��!P��DD���P��DD� P�v��݃��XP��DD��!P��DD�O܋�����,�z�DD�8 P�q�DD��!P�h�DD�@ �ؠ� 2�F��^���������H�DD�XP�?�DD���%� � ���F� P��P�oۃ�% � P�� P��P�׃�� �2�ÉF��ǉF��v� P��ك���!P���DD�^���������DD��!P���DD�^���������DD�XP��DD�@ �ؠ� 2�F���!P��DD�F�@ u���"P��DD�
��"P��DD�YP�y�DD��]_^�VWU����v�ƺ ������ �ƺ ������ �̓����t2�"P��DD�ƺ ������ �y�DD�'"P�p�DDW�j�DD���3��U�   u�s��  t�- P�p P�;ڃ�P�� P��P�Wփ��K�� P��P�ڃ��F�� %��P�� P��P�0փ��G�P�� P��P�փ��F�� P�� P��P�
փ��ƺ ��؊�� �F��v���P�x؃��ک t� P���DD��ک t� P���DD�3�P���DD�>$ u	�6j*�f�DD�   t'�ƺ ��؃�� @u�ƺ ������ ��P�Ճ���%� �F��ٹ ��$��F��~� u0�~� t*� P��P��׃��7"P�%�DD�D"P��DD�p"P��DD�� ��]_^�VWU���<ً���� �u"�7"P���DD�D"P���DD��"P���DD�X�3���P��P�v׃����q ��]_^�VWU��~W�3ˋ���t:��"P�ҋ��u��"P�ҋ��	��"P�ҋ�-"P�}ҋ�V�wҋ�����3��W�ԋ�>$ u	�6j*�3�� ]_^�U��LL�����ı��$�F��@ ���� uF����S��2�Ã>J Pw�>� w�����Àu[�>$ u	�6j*���DD��&� �[�����F��� ��]�U���ة t��"P���DD��"P��DD��ة t��"P��DD�#P��DD��3��� P��P�:փ�]�VU���׋���� ��� tA�t=�8#P�i�DD�d*P�`�DD�@#P�W�DD�b#P�N�DD�d*P�E�DD�l"P�<�DD��3��� ]^�VWU����0�!<s��#�F �^�F
 �,�Ȏؾ, ���3�2�� ��u�����؉~ �FW� ы�@�F�^�F�v�=֋���v �^�N��]_^��@ �؊J �6� U3ɷ�2��]���3���/  �1  �VU������F��F�t�F����F��� P��P�Xփ��F츅 P��P�Gփ��F븆 P��P�6փ��F��� P��P�%փ��F鸯 P��P�փ��F긊 P��P�փ��F��)P���DD�
 P�F����% P�׃���)P���DD�F���F���� P3�P��P��у�� @ t�F� %� P�� P��P��у���F� %� P�� P��P�у��F� %�  P�� P��P�у�� P�� P��P�у��v�� P��P�tу�� P�� P��P�bу��F� %� P�� P��P�Kу�� P3�P��P�:у�����@ �؊&l �V��u:&l u���t
:&l t��h�3��[��V��t��u��t��u��d �ΉV��F��V��t��u����t�+F�V��V��F�;V�wr;F�s�V��F��V��F�F��}��:θ P3�P��P�Ѓ�� � �F� P�� P��P�{Ѓ��F� P�� P��P�gЃ��F�� P�� P��P�SЃ��F� P�� P��P�?Ѓ��F� P�� P��P�+Ѓ��F� P�� P��P�Ѓ�� P3�P��P�Ѓ��~� v� r	�~��r� �F��F3�P�F���P�Ӄ��F��F�t�F���F����f��v�F��d ���v�F��
 P�v��'Ճ���)P�w�DD�
 P�F��
 3���P�	Ճ��
 P�F��
 3������V�+�R��ԃ���)P�;�DD�	��)P�0�DD��]^�U�츯 P��P�Ӌ� t2�*P�͋�^�����)��̋�+*P��̋帧)P��̋��k��3���v��΋� ]�U�츾 P��P��ҋ�P�� P��P��΋�~u��ϋ� ]�U�� P������v����� ]�VU��v�� P��P�uҋ� t3�*P�n̋��������2�_̋�5*P�V̋帧)P�M̋�����3��4��)&�?�u�����㊇4� P�5Ƌ�������㊇5� P�!Ƌ� ]^�      Stack overflow
 main     �Ŀ����� �ͻ���Ⱥ �Ĵ�����  Out of memory.  Sorry, my fault.
  0123456789abcdef  8(-
    qPZ
    8(-
dp    aPR       @ @((PP((PP,(-)*.)    5     :� F    J� U@   Y� d`   h� s�   wU@   Y�@   ��@  �%�UW�TV�GF  s���   w  $7  9  F�� ��  J  $7  9  U��@��  Y  $7  9 d��`��  h  $7  9 5� ��  :  $7   9  #    }!4  -9  9  9?   ��Q  -9  W gp@    �� �9   9 ��@@��  ���9   � ��    ��      	 	'	��  J	�     9 Q	Z	@    �	�      �	 �	�	@@��  J	�     9 �	�	    �	  :   
 

��  3
�     9 d*    l*  �!   � :
>
��  :
  �!  9 X
_
    r
  �!  {
 �
�
��  J	�    9 ��
    ��     	 	�
��  J	�    9� �
�
     �
  
"  �
�   ��  J	�    9@ &    A�     U@ ny��  ��    9@ ��    ��     �@ ����  ��    9@ � ��  %�    9@ ,2   G�    M@ kp ��  ��     9@ ����  ��    9@ ����  ��    9@ �	�	    �	  :   
@ 

��  3
�     9  ��        9  +   9  ��       9  +   9  9�       9  @?  9         9  @?  9  F       9  $7  9  U+       9  $7  9  �9       9  $7  9  �P       9  $7  9  gn       9  ?  �  ��       9  ?  �  ��       9  Y?   �  ��       9  Y?  9  �       9  Y?  9  )-       9  �>   J  [_       9  �>  9  |�       9  �>  9.  VGA Video BIOS Version x.xx. Current Selections Alternate Selections Use the UP and DOWN arrow keys to move up and down, the [Enter] key to select an item, or the [Esc] to key to exit to DOS. �	���> p_	G�
�
(
�	   �AUTO Auto Switch CGA CGA Locked MGA MGA Locked EGA EGA Locked VGA VGA Locked HERC0 Herc Half HERC1 Herc Full 132 by 25 132 by 43 800 by 600 Select VGA State Select CGA State Select MGA State Select EGA State Select Auto Switch State MONO Select MONO mode Mono COLOR Select COLOR mode Color  [ COLOR MONO ] STANDARD Select STANDARD VGA bandwidth Standard FAST Select FAST VGA bandwidth Fast  [ STANDARD FAST ] REVERSE Enable REVERSE VIDEO in text mode Text Reversed  [ REVERSE NOREVERSE ] NOREVERSE Disable REVERSE VIDEO in text mode Normal GREVERSE Enable REVERSE VIDEO in graphics mode Graphics Reversed  [ GREVERSE NOGREVERSE ] NOGREVERSE Disable REVERSE VIDEO in graphics mode 16BIT Allow 16 bit operation Allow16  [ 16BIT NO16BIT ] NO16BIT Force 8 bit operation Force8 CRT Switch the display to CRT EXPAND Enable EXPAND mode Expanded  [ EXPAND NOEXPAND ] NOEXPAND Disable EXPAND mode Enable REVERSE VIDEO Disable REVERSE VIDEO BOLD Enable BOLD mode Bold  [ BOLD NOBOLD ] NOBOLD Disable BOLD mode ATTREMUL Enable ATTRIBUTE EMULATION Attribute Emulation  [ ATTREMUL NOATTREMUL ] NOATTREMUL Enable AUTOMAP Automap CENTER CENTER unexpanded modes Centered  [ CENTER TOP BOTTOM ] TOP Display unexpanded modes from TOP Top BOTTOM Display unexpanded modes from BOTTOM Bottom SKIP9 Skip every 9th pixel Skip9  [ LEFT RIGHT SKIP9 OR8AND9 ] LEFT Display MGA modes from LEFT Left RIGHT Display MGA modes from RIGHT Right OR8AND9 Or 8th and 9th pixel or8and9 EXIT Exit to DOS Select VGA Color State Select VGA Mono State Set CGA State Set MGA State Set Hercules Half Mode Set Hercules Full Mode REBOOT Reboot System in Current State  [ REBOOT ] LOCK Lock the Current State  [ LOCK ] 13225 Switch to 132 x 25 Mode  [ 13225 13243 600 ] 13243 Switch to 132 x 43 Mode Switch to 800 x 600 Mode 200 Set 200 Scan Line Text Modes  [ 200 350 400 ] 350 Set 350 Scan Line Text Modes 400 Set 400 Scan Line Text Modes 
EXPAND Mode is not available with your current configuration.
 See your User Manual.
 
BOLD Mode is not available with your current configuration.
  , VGA Controller Utility Version   - AT&T VIDEO MODE SWITCH UTILITY  Switch the display to                                                             [ CRT                                                                               unknown         5.01 Copyright (C) Cirrus Logic Inc., 1987-1990.  All Rights Reserved. 
  cannot run in this environment.
 Video BIOS Version 2.20 or later is required to
 run this utility.
 PANEL Panel panel NTSC  ] MONO COLOR 
System ROM BIOS date is   is a bad switch character.
  is an unrecognized keyword.  You must enter at least
 three letters for a keyword to be recognized  is an unrecognized keyword 
Use   -? for more information on keywords and options.
 
Press [Enter] to go to menu mode,  or [Esc] to return to DOS:  Usage is:   [ -dsvc ]  [  
Switch Characters:
    -d           Gives System ROM BIOS Date.
    -s           Gives status information.
    -v           Gives extended status information.
    -c           Gives dot clocks in extended status information.
 State Control Keywords:
     User Option Keywords:
 EXIT 

 
Press almost any key to continue.                                        AUTO  Switch  State  has been set.
 Press almost any key to continue.  ���"&*.@LSd}}}}���t*� ����  (AV l�� ������ �� �#=Xm����������������	0W����!Kx������-=Nfx��=��EGA CGA (From EGA State) MGA (From EGA State) EGA Enhanced Text VGA CGA MGA VGA Enhanced Text  Monochrome  Color n Enhanced Color  Digital Multi-Frequency n Unknown type of n IBM PS/2 Analog n Analog Multi-Frequency Display type is set to  CRT Expanded mode is  enabled disabled Ram access is set to  allow 16 bit force 8 bit Reverse video is set to  enable reverse video disable reverse video Attribute emulation is set to  AUTOMAP Bold font is  VGA bandwidth is set to  standard fast center unexpanded modes display unexpanded modes at top display unexpanded modes at bottom display MGA modes at left display MGA modes at right skip every 9th pixel or 8th and 9th pixel Free running line clock, dot clock/2 Constrained line clock, dot clock/2 Reserved Balanced line clock, dot clock/2 Balanced line clock MDA Prim, EGA w/ CD in 40 col mode Sec MDA Prim, EGA w/ CD in 80 col mode Sec MDA Prim, EGA w/ ECD in 200 scan mode Sec MDA Prim, EGA w/ ECD in 350 scan mode Sec CGA in 40 col mode Prim, EGA + MD Sec CGA in 80 col mode Prim, EGA + MD Sec EGA w/ CD in 40 col mode Prim, MDA/no Sec EGA w/ CD in 80 col mode Prim, MDA/no Sec EGA w/ ECD in 200 scan mode Prim, MDA/no Sec EGA w/ ECD in 350 scan mode Prim, MDA/no Sec EGA w/ MD Prim, CGA in 40 col mode/no Sec EGA w/ MD Prim, CGA in 80 col mode/no Sec an invalid EGA setting No Display an MDA with an MD a CGA with a CD a reserved value an EGA with a CD or ECD an EGA with an MD a PGA with a 5175 a VGA with an Analog Monochrome Monitor a VGA with an Analog Color Monitor an MCGA with a CD or ECD an MCGA with an Analog Monochrome Monitor an MCGA with an Analog Color Monitor 
Cold boot state will be  .
 Warm boot state will be  .
Current state is  The VGA is currently in a  COLOR (3Dx) MONO (3Bx)  mode.
 Force 8 bit operation is enabled 16 bit operation has been disabled
       due to the co-resident CGA      due to the co-resident MGA      because the PC bus interface is 8 bit The VGA is running as a 16 bit device The VGA is running as an 8 bit device Text reverse video is set to  disable text reverse video enable text reverse video Graphics reverse video is set to  disable graphics reverse video enable graphics reverse video .  16 bit operation has been disabled
  .  The VGA is running as a 16 bit device .  The VGA is running as an 8 bit device Centering is set to  MGA reduction is set to  Hardware Configuration:
     The active ROM Video BIOS is located at segment  E000h C000h     The CL-GD5320 chip revision number is 0x     The CL-GD  (G/A) version number is 0x  (S/C) version number is 0x     This VGA is auto switchable.
     There is  a co-resident Color Graphics Adapter  (CGA).
 a co-resident Monochrome Display  Adapter (MDA or Hercules).
 no co-resident MDA or CGA.
     The installed video memory is   kbytes.
     The   type is a      CMOS configuration byte is set for a     Physical switches are set for a  Display.
      Hardware State:
     Current Video State is      EGA Virtual switches are  Software Configuration:
     System ROM BIOS date is      VGA BIOS version is  .     System ROM BIOS CGA/MGA parameters are  NOT  IBM Compatible.
 Software State:
     Current Video Mode is   on the co-resident adapter 0/1+ 2/3+ 7+ 7 *     Logical switches are set for a     EGA configuration is      Active DCC is  .
    Alternate DCC is      Display switch is  enabled. disabled.  
Cannot set   state because  
WARNING:  PROTECT Mode is not allowed in AUTO Mode.
 PROTECT Mode has been cleared.
 PROTECT Mode will not be set.

 
Cannot change mode to  Mono Color 
16 bit operation is not allowed  due to the co-resident CGA.
 due to the co-resident MGA.
 
The   only runs in VGA Locked State.
 Change the state to VGA Locked to switch to   Eagle.COM of the co-resident monochrome
card.
 your Color Display is not able
to run at MGA frequency.
 your Enhanced Color Display is
not able to run at MGA frequency.
 of the co-resident Color
Graphics Adapter.
 your Monochrome Display is not
able to run at CGA frequency.
 the EGA modes in which you
must run, because of the attached Monochrome Display, would conflict
with the co-resident monochrome card.
 the EGA modes in which you
must run, because of the attached Color Display, would conflict with
the co-resident Color Graphics Adapter.
 the EGA modes in which you
must run, because of the attached Enhanced Color Display, would 
conflict with the co-resident Color Graphics Adapter.
 the VGA modes in which you
must run, because of the attached Monochrome Display, would conflict
with the co-resident monochrome card.
 the VGA modes in which you
must run, because of the attached Color Display, would conflict with
the co-resident Color Graphics Adapter.
 the EGA modes in which you
must run, because of the attached Enhanced Color Display, would
conflict with the co-resident Color Graphics Adapter.
 of the co-resident Color Graphics
Adapter.
 there are no color modes in
MGA locked state.
 your Monochrome display is not
capable of running at color frequencies.
 of the co-resident monochrome
card.
 there are no monochrome modes in
CGA locked state.
 your Color Display is not capable
of running at monochrome frequency.
 your Enhanced Color Display is
not capable of running at monochrome frequency.
 the VGA adapter is not in VGA state.
 clock   is  .  mHz     not connected  c  �)**200 Scans 350 Scans 400 Scans 
Cannot set   because   mode because  �  [� ��!<u2���S.�<MZt� � W��Á�S��.�G �P.�GP�v��S��H��&�>  Zt0�H����!��q�r@�H�!r:H���&�   &�>  Zu'& @&� &� -q r&� &�. q�&� ����[�l�[S�Ȏ،G:�w ��������!5�!�i �k [S��8.��5���m �q �s �!%����m �%����m [���5�!�Z �\ �%���!�^ ���P��X P��P�*��Z �%�^ .�>^ u.�i .�k .�m .�o �X%��P��.�.i U��.�>^ t�f��.�^  ]ρ~ r]�S�^.�m �^.�o [�֜�.�m ð�ϰ�.�u �= �t��Kt�.�.i �PSQRWVU.�Z .�\ � 3����^ �32����/���_ �a 3Ҵ���$5���c �e �$%����N�7 �Z �}�s�� .� �u�1 .; r��.�Z �C�  �V�rٸ=�N�r��g �ظB�������9��?�- �, �.�rs�O���I ��� 󦜠u 
�u� �u�g �B����~����rϴ@3����rƸ B3ɋ����r��@� �- ����g �W� � ����>����Z .� 2��C��.�c �$%��.�_ ���.�^ �3��]^_ZY[X�.�.i �g �B3ɋ��r�rT�@���w �e�rG� B3ɋ��Y�r;Ýu�w��g � B3ɋ��B�r$�?� ���5�r�>�MZt�>  u�>  �r�@��>�MZt!���- � ���. �@� �- ��������- �� � � � ������ ��= ��; ;�s����:�� � � ��A +5 �C � ��  � � � ���t@�1 �/ �@� �- �u����� ߼�����߅������ߐ�����ߛ������ߗ�����߼�����߅������ߐ�������ߛ������ߗ����ќ� ���   �����  ! # 3 5 E G W `   �PSQRVWU� ����@ ��.�>� u5�>n u�>l G�u�I <t<t� ���<t]_^ZY[X�.�.q �� .���l �t���t�9��t�{��t� .�� ���u��a$��a�����C���B���B.����.�6�.��t;�u�FF.�6�.���a�a�.��.�>��Ȏع& ��������ЪG���.�6�.�;�u�FF.�6�.���a$��a�q���iu4.�>����؋���� ����.��.��.���F�^�N.�� ���.��.��.����N .��������� ������� �����Ȏع& �������ЪG����F�^�N.��.��.�����ˉF�^��� 
If I were looking at ��ߕ���ߴ�������