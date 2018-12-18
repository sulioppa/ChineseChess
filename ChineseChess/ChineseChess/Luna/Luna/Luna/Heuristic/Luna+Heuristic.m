//
//  Luna+Heuristic.m
//  Luna
//
//  Created by 李夙璃 on 2018/11/21.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+Heuristic.h"

#include <stdlib.h>
#include <memory.h>

// MARK: - LCHistoryTrack Life Cycle
LCMutableHistoryTrackRef LCHistoryTrackCreateMutable(void) {
    unsigned long size = sizeof(LCHistoryTrack) * LCBoardMapLength;
    
    void *memory = malloc(size);
    memset(memory, 0, size);
    
    return memory == NULL ? NULL : (LCHistoryTrack *)memory;
}

void LCHistoryTrackClear(LCMutableHistoryTrackRef history) {
    unsigned long size = sizeof(LCHistoryTrack) * LCBoardMapLength;
    
    memset(history, 0, size);
}

void LCHistoryTrackRelease(LCHistoryTrackRef history) {
    if (history == NULL) {
        return;
    }
    
    free((void *)history);
}
