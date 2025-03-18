import { createSlice } from "@reduxjs/toolkit";
import { createSelectors, createSetters, VariablesOf } from "../common/sliceUtils";
import { useAppSelector } from "../../app/hooks";
import { SyncConfig } from "./entities/syncConfig.ts";

interface State {
    syncConfig: SyncConfig | undefined;
    initialized: boolean;
}

const storedSyncConfig = localStorage.getItem("syncConfig");
const initialState: State = {
    syncConfig: storedSyncConfig ? JSON.parse(storedSyncConfig) : undefined,
    initialized: false,
};

const variables: VariablesOf<State> = ["syncConfig", "initialized"] as const;

const reducers = createSetters<State>()(variables);
const slice = createSlice({
    name: "syncConfigSlice",
    reducerPath: "syncConfig",
    initialState,
    reducers: {
        ...reducers,
        setSyncConfig: (state, action) => {
            state.syncConfig = action.payload;
            if (action.payload === undefined) {
                state.initialized = false;
                return;
            }
            localStorage.setItem("syncConfig", JSON.stringify(action.payload)); // Store in localStorage
        },
        clearSyncConfig: (state) => {
            state.syncConfig = undefined;
            localStorage.removeItem("syncConfig"); // Remove from localStorage
        },
    },
});

const selectors = {
    ...createSelectors(slice)(variables),
};

// ----
export const syncConfigSliceReducer = slice.reducer;
export const syncConfigSelectors = selectors;
export const syncConfigActions = {
    ...slice.actions,
};

export const syncConfigSlice = slice;

export const useSyncConfig = () => useAppSelector(syncConfigSelectors.syncConfig);
