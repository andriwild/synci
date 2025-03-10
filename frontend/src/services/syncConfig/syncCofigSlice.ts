import {createSlice} from "@reduxjs/toolkit";
import {createSelectors, createSetters, VariablesOf} from "../common/sliceUtils";
import {useAppSelector} from "../../app/hooks";
import {SyncConfig} from "./entities/syncConfig.ts";

interface State {
    syncConfig: SyncConfig|undefined;
    initialized: boolean
}

const initialState: State = {
    syncConfig: undefined,
    initialized: false,
}

const variables: VariablesOf<State> = [
    "syncConfig",
    "initialized"
] as const

const reducers = createSetters<State>()(variables)
const slice = createSlice({
    name: "syncConfigSlice",
    reducerPath: "syncConfig",
    initialState,
    reducers: {
        ...reducers,
    }
})

const selectors = {
    ...createSelectors(slice)(variables),
}

// ----
export const syncConfigSliceReducer = slice.reducer;
export const syncConfigSelectors = selectors;
export const syncConfigActions = {
    ...slice.actions,
}

export const syncConfigSlice = slice;

export const useSyncConfig = ()=>useAppSelector(syncConfigSelectors.syncConfig);
