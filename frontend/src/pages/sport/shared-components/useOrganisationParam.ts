import {useEffect} from "react";
import {useSearchParams} from "react-router-dom";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {sportNode, TreeNode} from "./treeNodes.ts";

/** Search parameter that opens an organisation in the sport tree, e.g. from the organisations page. */
export const ORGANISATION_PARAM = "organisation";

/**
 * Opens the organisation named in `?organisation=<id>` once it is loaded, then drops the parameter
 * so it does not override later clicks. `open` must be stable (useCallback).
 */
export const useOrganisationParam = (organisations: MyOrganisation[], open: (node: TreeNode) => void) => {
    const [searchParams, setSearchParams] = useSearchParams();
    const id = searchParams.get(ORGANISATION_PARAM);

    useEffect(() => {
        if (!id) return;
        const organisation = organisations.find((o) => o.id === id);
        if (!organisation) return;
        open(sportNode(organisation.sport, organisation));
        setSearchParams((params) => {
            params.delete(ORGANISATION_PARAM);
            return params;
        }, {replace: true});
    }, [id, organisations, open, setSearchParams]);
};
