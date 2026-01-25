 Z←DET A;B;P;I
 I←⌷IO
 Z←1
L:P←(|A[;I])⍳⌈/|A[;I]
 →(P=I)/LL
 A[I,P;]←A[P,I;]
 Z←-Z
LL:Z←Z×B←A[I;I]
 →(0 1∨.=Z,1↑⍴A)/0
 A←1 1↓A-(A[;I]÷B)∘.×A[I;]
 →L