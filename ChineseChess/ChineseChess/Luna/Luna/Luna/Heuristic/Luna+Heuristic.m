//
//  Luna+Heuristic.m
//  Luna
//
//  Created by 李夙璃 on 2018/11/21.
//  Copyright © 2018 李夙璃. All rights reserved.
//

#import "Luna+Heuristic.h"

#include <stdlib.h>
#include <memory.h>

// MARK: - LCHistoryTrack Life Cycle
LCMutableHistoryTrackRef LCHistoryTrackCreateMutable(void) {
    void *memory = malloc(sizeof(LCHistoryTrack));
    memset(memory, 0, sizeof(LCHistoryTrack));
    
    return memory == NULL ? NULL : (LCHistoryTrack *)memory;
}

void LCHistoryTrackClear(LCMutableHistoryTrackRef history) {
    memset(history, 0, sizeof(LCHistoryTrack));
}

void LCHistoryTrackRelease(LCHistoryTrackRef history) {
    if (history == NULL) {
        return;
    }
    
    free((void *)history);
}
