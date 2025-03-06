import {PayloadAction, Slice} from "@reduxjs/toolkit";
import {capitalize} from "../../utils/stringUtils";
import {RootState} from "../../app/store";

export type SetterFn<S, K extends keyof S> = (state: S, action: PayloadAction<S[K]>) => void;
export type SetterCreatorFn<S> = <K extends keyof S>(propName: K) => SetterFn<S,K>;

export function createSetter<S>(): SetterCreatorFn<S> {
    return <K extends keyof S>(propName: K): SetterFn<S,K> => {
        return (state: S, action: PayloadAction<S[K]>) => {
            state[propName] = action.payload;
        }
    }
}

export type SliceSelector<ST> = (state: RootState)=>ST;

export function createGetters<ST>(sliceSelector: SliceSelector<ST>) {
    const sel = <R>(selectorFn: (sliceState: ST) => R) => {
        return (state: RootState) => selectorFn(sliceSelector(state));
    }
    const getter = <K extends keyof ST>(propName: K) => {
        return sel(state => state[propName]);
    }

    return {
        sel,
        getter
    };
}

export const createSetters = <S>() => <
    K extends keyof S, 
    R = {[P in K as P extends string ? `set${Capitalize<P>}` : never]: SetterFn<S, P>}
>(keys: K[]): R => {
    const setter = createSetter<S>();

    return Object.fromEntries(keys.map(k=>([
        `set${capitalize(k.toString())}`, 
        setter(k)
    ]))) as unknown as R
}

export const buildGetters = <ST>(sliceSelector: SliceSelector<ST>) => <
    K extends keyof ST,
    R = {[P in K]: (state: RootState)=>ST[P]}
>(keys: K[]): R => {
    const {getter} = createGetters(sliceSelector);

    return Object.fromEntries(keys.map(k=>([
        k,
        getter(k)
    ]))) as unknown as R
}

export const createSelectors = <ST>(slice: Slice<ST>) => {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore 
    const sliceSelector: SliceSelector<ST> = state => state[slice.reducerPath]

    return buildGetters(sliceSelector);
}

export type VariablesOf<ST, K = keyof ST> = K[];
