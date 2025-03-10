import { createSlice } from "@reduxjs/toolkit";
import { User } from "./entities/User";
import { createSelectors, createSetters, VariablesOf } from "../common/sliceUtils";
import { useAppSelector } from "../../app/hooks";

interface State {
    user: User | undefined;
    initialized: boolean;
}

// Retrieve user from localStorage if it exists
const storedUser = localStorage.getItem("user");
const initialState: State = {
    user: storedUser ? JSON.parse(storedUser) : undefined,
    initialized: false,
};

const variables: VariablesOf<State> = ["user", "initialized"] as const;

const reducers = createSetters<State>()(variables);
const slice = createSlice({
    name: "userSlice",
    reducerPath: "user",
    initialState,
    reducers: {
        ...reducers,
        setUser: (state, action) => {
            state.user = action.payload;
            localStorage.setItem("user", JSON.stringify(action.payload)); // Store in localStorage
        },
        clearUser: (state) => {
            state.user = undefined;
            localStorage.removeItem("user"); // Remove from localStorage
        },
    },
});

const selectors = {
    ...createSelectors(slice)(variables),
};

// ----
export const userSliceReducer = slice.reducer;
export const userSelectors = selectors;
export const userActions = {
    ...slice.actions,
};

export const userSlice = slice;

export const useUser = () => useAppSelector(userSelectors.user);
