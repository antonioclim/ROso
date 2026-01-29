# Ghid Studiu — Gestiune Memorie P1

## Concepte Cheie

### Paginare
- Memoria logică: pagini (dimensiune fixă)
- Memoria fizică: frame-uri (același size)
- Page Table: mapare pagină → frame
- Elimină fragmentarea externă

### Segmentare
- Unități logice: code, data, stack
- Dimensiuni variabile
- Fragmentare externă posibilă

### Page Table Entry (PTE)
- Frame number
- Valid/invalid bit
- Protection bits (rwx)
- Dirty bit
- Reference bit

## Formule
- Offset bits = log₂(page_size)
- Page number bits = address_bits - offset_bits
- Max pages = 2^(page_number_bits)
