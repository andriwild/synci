import {Action, configureStore, ThunkAction} from "@reduxjs/toolkit";
import {categoryApi} from "../services/category/categoryApi.ts";

export const store = configureStore({
    reducer: {
        [categoryApi.reducerPath]: categoryApi.reducer,

    },
    middleware: getDefaultMiddleware =>
        getDefaultMiddleware()
            .concat(categoryApi.middleware)
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType,
    RootState,
    unknown,
    Action<string>>;
