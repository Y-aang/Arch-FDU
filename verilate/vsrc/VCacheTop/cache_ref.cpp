#include "mycache.h"
#include "cache_ref.h"
#include <math.h>

word_t get_offset(addr_t add){
	return (add>>3) % 16;
}
word_t get_index(addr_t add){
	return (add>>7) % 8;
}
word_t get_tag(addr_t add){
	return (add>>10);
}

// word_t get_offset(addr_t add){
// 	return (add/1000) % 10000;
// }
// word_t get_index(addr_t add){
// 	return (add/10000000) % 1000;
// }
// word_t get_tag(addr_t add){
// 	return (add/10000000000);
// }
word_t convertBinaryToDecimal(addr_t n)
{
    addr_t decimalNumber = 0, i = 0, remainder;
    while (n!=0)
    {
        remainder = n%10;
        n /= 10;
        decimalNumber += remainder*pow(2,i);
        ++i;
    }
    return decimalNumber;
}
addr_t convertDecimalToBinary(word_t n)
{
    word_t binaryNumber = 0;
    word_t remainder, i = 1, step = 1;
 
    while (n!=0)
    {
        remainder = n%2;
        printf("Step %d: %d/2, 余数 = %d, 商 = %d\n", step++, n, remainder, n/2);
        n /= 2;
        binaryNumber += remainder*i;
        i *= 10;
    }
    return binaryNumber;
}

CacheRefModel::CacheRefModel(MyCache *_top, size_t memory_size)
	: top(_top), scope(top->VCacheTop), mem(memory_size)
{
	mem.set_name("ref");
#ifdef REFERENCE_CACHE
	// REFERENCE_CACHE does nothing else
#else
	/**
	 * TODO (Lab3) setup reference model :)
	 */
	word_t data_array[8][2][16];
	struct meta_t
	{
		word_t valid;
		word_t dirty;
		word_t tag;
	};
	meta_t meta[8][2];
	word_t LRU[8][2];

#endif
}

void CacheRefModel::reset()
{
	log_debug("ref: reset()\n");
	mem.reset();
#ifdef REFERENCE_CACHE
	// REFERENCE_CACHE does nothing else
#else
	/**
	 * TODO (Lab3) reset reference model :)
	 */



	// for(int i = 0; i < 8; i++){
	// 	for(int j = 0; j < 2; j++){
	// 		meta[i][j].valid = 0;
	// 		meta[i][j].dirty = 0;
	// 		meta[i][j].tag = 0;
	// 		LRU[i][j] = j;
	// 	}
	// }
	// for(int i = 0; i < 8; i++){
	// 	for(int j = 0; j < 2; j++){
	// 		for(int k = 0; k < 16; k++){
	// 			data_array[i][j][k] = 0;
	// 		}
	// 	}
	// }
#endif
}

auto CacheRefModel::load(addr_t addr, AXISize size) -> word_t
{
	log_debug("ref: load(0x%lx, %d)\n", addr, 1 << size);
#ifdef REFERENCE_CACHE
	addr_t start = addr / 128 * 128;
	for (int i = 0; i < 16; i++) {
		buffer[i] = mem.load(start + 8 * i);
	}

	return buffer[addr % 128 / 8];
#else
	/**
	 * TODO (Lab3) implement load operation for reference model :)
	 */


	// addr_t start = addr / 128 * 128;
	// for (int i = 0; i < 16; i++) {
	// 	buffer[i] = mem.load(start + 8 * i);
	// }

	// return buffer[addr % 128 / 8];

	return mem.load(addr);



	// word_t set, offset, tag;
	// set = (get_index(addr));
	// offset = (get_offset(addr));
	// tag = (get_tag(addr));

	// // printf("set=%llx\n", set);
	// // printf("offset=%llx\n", offset);
	// // printf("tag=%llx\n", tag);

	// for(int i = 0; i < 2; i++){//找到
	// 	if(meta[set][i].valid == 1 && meta[set][i].tag == tag){
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 		return data_array[set][i][offset];
	// 	}
	// }
	// for(int i = 0; i < 2; i++){//没找到
	// 	if(LRU[set][i] == 0 ){
	// 		if(meta[set][i].dirty == 1){
	// 			for(int j = 0; j<16; j++){//回写
	// 				mem.store(((addr>>7)<<7) + (j * 8) , data_array[set][i][j], 0xffffffff);
	// 			}
	// 		}
	// 		for(int j = 0; j<16; j++){//写入cache
	// 			data_array[set][i][j] = mem.load(((addr>>7)<<7) + (j * 8));
	// 		}
	// 		meta[set][i].valid = 1;
	// 		meta[set][i].dirty = 0;
	// 		meta[set][i].tag = tag;
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 	}
	// }
	// for(int i = 0; i < 2; i++){//找到
	// 	if(meta[set][i].valid == 1 && meta[set][i].tag == tag){
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 		return data_array[set][i][offset];
	// 	}
	// }
#endif
}

void CacheRefModel::store(addr_t addr, AXISize size, word_t strobe, word_t data)
{

	log_debug("ref: store(0x%lx, %d, %x, \"%016x\")\n", addr, 1 << size, strobe, data);
#ifdef REFERENCE_CACHE
	addr_t start = addr / 128 * 128;
	for (int i = 0; i < 16; i++) {
		buffer[i] = mem.load(start + 8 * i);
	}

	auto mask1 = STROBE_TO_MASK[strobe & 0xf];
	auto mask2 = STROBE_TO_MASK[((strobe) >> 4) & 0xf];
	auto mask = (mask2 << 32) | mask1;
	auto &value = buffer[addr % 128 / 8];
	value = (data & mask) | (value & ~mask);
	mem.store(addr, data, mask);
	return;
#else
	/**
	 * TODO (Lab3) implement store operation for reference model :)
	 */

	// addr_t start = addr / 128 * 128;
	// for (int i = 0; i < 16; i++) {
	// 	buffer[i] = mem.load(start + 8 * i);
	// }

	auto mask1 = STROBE_TO_MASK[strobe & 0xf];
	auto mask2 = STROBE_TO_MASK[((strobe) >> 4) & 0xf];
	auto mask = (mask2 << 32) | mask1;
	// auto &value = mem.load(addr);
	// auto &value = buffer[addr % 128 / 8];
	// value = (data & mask) | (value & ~mask);
	mem.store(addr, data, mask);
	return;

	


	// auto mask1 = STROBE_TO_MASK[strobe & 0xf];
	// auto mask2 = STROBE_TO_MASK[((strobe) >> 4) & 0xf];
	// auto mask = (mask2 << 32) | mask1;
	// word_t value = (data & ~mask) | (data & mask);

	// // printf("value=%llx\n", value);

	// word_t set, offset, tag;
	// set = (get_index(addr));
	// offset = (get_offset(addr));
	// tag = (get_tag(addr));

	// // printf("set=%llx\n", set);
	// // printf("offset=%llx\n", offset);
	// // printf("tag=%llx\n", tag);

	// for(int i = 0; i < 2; i++){//找到
	// 	if(meta[set][i].valid == 1 && meta[set][i].tag == tag){
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 		// data_array[int(set)][i][int(offset)] = value;
	// 		value = data_array[int(set)][i][int(offset)];
	// 		value = (data & mask) | (value & ~mask);
	// 		data_array[int(set)][i][int(offset)] = value;
	// 		meta[set][i].dirty = 1;
	// 		return;
	// 	}
	// }
	// for(int i = 0; i < 2; i++){//没找到
	// 	if(LRU[set][i] == 0 ){
	// 		if(meta[set][i].dirty == 1){
	// 			for(int j = 0; j<16; j++){//回写
	// 				mem.store(((addr>>7)<<7) + (j * 8) , data_array[set][i][j], 0xffffffff);
	// 			}
	// 		}
	// 		for(int j = 0; j<16; j++){//写入cache
	// 			data_array[set][i][j] = mem.load(((addr>>7)<<7) + (j * 8));
	// 		}
	// 		meta[set][i].valid = 1;
	// 		meta[set][i].dirty = 0;
	// 		meta[set][i].tag = tag;
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 	}
	// }
	// for(int i = 0; i < 2; i++){//找到
	// 	if(meta[set][i].valid == 1 && meta[set][i].tag == tag){
	// 		LRU[set][i] = 1;
	// 		LRU[set][1-i] = 0;
	// 		// data_array[set][i][offset] = value;
	// 		value = data_array[int(set)][i][int(offset)];
	// 		value = (data & mask) | (value & ~mask);
	// 		data_array[int(set)][i][int(offset)] = value;
	// 		meta[set][i].dirty = 1;
	// 		return;
	// 	}
	// }
#endif
}

void CacheRefModel::check_internal()
{
	log_debug("ref: check_internal()\n");
#ifdef REFERENCE_CACHE
	/**
	 * the following comes from StupidBuffer's reference model.
	 */
	for (int i = 0; i < 16; i++) {
		asserts(
			buffer[i] == scope->mem[i],
			"reference model's internal state is different from RTL model."
			" at mem[%x], expected = %016x, got = %016x",
			i, buffer[i], scope->mem[i]
		);
	}
#else
	/**
	 * TODO (Lab3) compare reference model's internal states to RTL model :)
	 *
	 * NOTE: you can use pointer top and scope to access internal signals
	 *       in your RTL model, e.g., top->clk, scope->mem.
	 */
	// for (int i = 0; i < 16; i++) {
	// 	asserts(
	// 		buffer[i] == scope->mem[i],
	// 		"reference model's internal state is different from RTL model."
	// 		" at mem[%x], expected = %016x, got = %016x",
	// 		i, buffer[i], scope->mem[i]
	// 	);
	// }

#endif
}

void CacheRefModel::check_memory()
{
	log_debug("ref: check_memory()\n");
#ifdef REFERENCE_CACHE
	/**
	 * the following comes from StupidBuffer's reference model.
	 */
	asserts(mem.dump(0, mem.size()) == top->dump(), "reference model's memory content is different from RTL model");
#else
	/**
	 * TODO (Lab3) compare reference model's memory to RTL model :)
	 *
	 * NOTE: you can use pointer top and scope to access internal signals
	 *       in your RTL model, e.g., top->clk, scope->mem.
	 *       you can use mem.dump() and MyCache::dump() to get the full contents
	 *       of both memories.
	 */

#endif
}
