void relocate(uint8_t *text, uint8_t *data, uint32_t new_text, uint32_t new_data, uint32_t new_entry)
{
	reloc_t *rel;
	uint32_t *src, dst;
	for (rel = (reloc_t*)data; ! IS_FINI(*rel); rel++)
		if (DST_FRAG(*rel) != 2) { /* skip external symbols, they will be resolved at run-time */
			/* pointer to the value that must be fixed */
			src = (uint32_t*)((SRC_FRAG(*rel) == 1 ? data : text) + SRC_OFF(*rel));
			/* there is only one internal symbol ("frag" 3) left: __entry */
			dst = DST_FRAG(*rel) == 3 ? new_entry : (DST_FRAG(*rel) ? new_data : new_text) + DST_OFF(*rel);
			/* patch in absolute/relative value */
			*src = SRC_TYPE(*rel) == 0 ? dst : dst - ((SRC_FRAG(*rel) ? new_data : new_text) + SRC_OFF(*rel) + 4);
		}
}
