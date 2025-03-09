import {Action, configureStore, ThunkAction} from "@reduxjs/toolkit";
import {sportApi} from "../services/sport/sportApi.ts";
import {userApi} from "../services/user/userApi.ts";

export const store = configureStore({
    reducer: {
        [sportApi.reducerPath]: sportApi.reducer,
        [userApi.reducerPath]: userApi.reducer,


    },
    middleware: getDefaultMiddleware =>
        getDefaultMiddleware()
            .concat(sportApi.middleware)
            .concat(userApi.middleware),
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType,
    RootState,
    unknown,
    Action<string>>;
