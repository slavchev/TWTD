 R←DET2 A;M;N;I;J;K;T;P
 M←A
 N←1↑⍴M
 P←1
 I←1
L1:→(I>N)/L7
 K ←I
 J←I
L2:J←J+1
 →(J>N)/L3
 →((|M[J;I])≤|M[K;I])/L2
 K←J
 →L2
L3:→(K=I)/L4
 T←M[I;]
 M[I;]←M[K;]
 M[K;]←T
 P←-P
L4:→(M[I;I]=0)/L8
 J←I
L5:J←J+1
 →(J>N)/L6
 M[J;]←M[J;]-(M[J;I]÷M[I;I])×M[I;]
 →L5
L6:I←I+1
 →L1
L7:R←P××/1 1⍉M
 →0
L8:R←0