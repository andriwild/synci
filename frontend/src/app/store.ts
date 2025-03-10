import {Action, configureStore, ThunkAction} from "@reduxjs/toolkit";
import {sportApi} from "../services/sport/sportApi.ts";
import {userSliceReducer} from "../services/user/UserSlice.ts";
import {syncConfigApi} from "../services/syncConfig/syncConfigApi.ts";
import {syncConfigSliceReducer} from "../services/syncConfig/syncCofigSlice.ts";

export const store = configureStore({
    reducer: {
        user: userSliceReducer,
        syncConfig: syncConfigSliceReducer,
        [sportApi.reducerPath]: sportApi.reducer,
        [syncConfigApi.reducerPath]: syncConfigApi.reducer
    },
    middleware: getDefaultMiddleware =>
        getDefaultMiddleware()
            .concat(sportApi.middleware)
            .concat(syncConfigApi.middleware)
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType,
    RootState,
    unknown,
    Action<string>>;
