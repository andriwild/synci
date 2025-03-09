import {createSlice} from "@reduxjs/toolkit";
import {User} from "./entities/User";
import {createSelectors, createSetters, VariablesOf} from "../common/sliceUtils";
import {useAppSelector} from "../../app/hooks";

interface State {
    user: User|undefined;
    initialized: boolean
}

const initialState: State = {
    user: undefined,
    initialized: false,
}

const variables: VariablesOf<State> = [
    "user",
    "initialized"
] as const

const reducers = createSetters<State>()(variables)
const slice = createSlice({
    name: "userSlice",
    reducerPath: "user",
    initialState,
    reducers: {
        ...reducers,
    }
})

const selectors = {
    ...createSelectors(slice)(variables),
}


// ----
export const userSliceReducer = slice.reducer;
export const userSelectors = selectors;
export const userActions = {
    ...slice.actions,
}

export const userSlice = slice;

export const useUser = ()=>useAppSelector(userSelectors.user);
