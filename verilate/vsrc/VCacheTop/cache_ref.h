#pragma once

#include "defs.h"
#include "memory.h"
#include "reference.h"

class MyCache;

class CacheRefModel final : public ICacheRefModel {
public:
	CacheRefModel(MyCache *_top, size_t memory_size);

	void reset();
	auto load(addr_t addr, AXISize size)->word_t;
	void store(addr_t addr, AXISize size, word_t strobe, word_t data);
	void check_internal();
	void check_memory();

private:
	MyCache *top;
	VModelScope *scope;
#ifdef REFERENCE_CACHE
	word_t buffer[16];
#else
	/**
	 * TODO (Lab3) declare reference model's memory and internal states :)
	 *
	 * NOTE: you can use BlockMemory, or replace it with anything you like.
	 */

	word_t buffer[16];

	


	// word_t data_array[8][2][16];
	// struct meta_t
	// {
	// 	word_t valid;
	// 	word_t dirty;
	// 	word_t tag;
	// }meta[8][2];
	// word_t LRU[8][2];
#endif

	 // int state;
	BlockMemory mem;

	// word_t data[8][2][16];
	// struct meta_t
	// {
	// 	word_t valid;
	// 	word_t dirty;
	// 	word_t tag;
	// }meta[8][2];
	// word_t LRU[8][2];
};
