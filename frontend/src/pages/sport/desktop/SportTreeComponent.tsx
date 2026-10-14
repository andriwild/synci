import {useMemo, useState} from "react";
import {Flex} from "antd";
import "./SportTreeComponent.css";
import {CaretRight, Compass, UsersThree} from "@phosphor-icons/react";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {SportDetailComponent} from "../shared-components/SportDetailComponent.tsx";
import {ErrorState, LoadingState} from "../shared-components/TreeStates.tsx";
import {useUser} from "../../../services/user/UserSlice.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {activeOrganisations, childNodes, firstColumn, hasChildren, TreeNode, withLiveOrganisation} from "../shared-components/treeNodes.ts";
import {DiscoverOrganisationsPanel} from "../../organisation/components/DiscoverOrganisationsPanel.tsx";
import {track} from "../../../utils/analytics.ts";

type TreeColumn = { nodes: TreeNode[] };

const columnColors = ["#3D5A80", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];

export const SportTreeComponent = () => {
    const user = useUser();
    const sportTree = sportApi.useGetAllQuery();
    const myOrganisations = organisationApi.useGetMineQuery(undefined, {skip: !user});

    /** selected node per column level; the columns are derived from it */
    const [path, setPath] = useState<TreeNode[]>([]);

    const organisations = useMemo(() => activeOrganisations(myOrganisations.data), [myOrganisations.data]);

    // drop the selection as soon as an organisation or group in it disappeared, otherwise refresh its data
    const livePath = useMemo(() => {
        const result: TreeNode[] = [];
        for (const node of path) {
            const live = withLiveOrganisation(node, organisations);
            if (!live) break;
            result.push(live);
        }
        return result;
    }, [path, organisations]);

    if (sportTree.isLoading) {
        return <LoadingState/>;
    }
    if (sportTree.isError) {
        return <ErrorState error={sportTree.error}/>;
    }

    // "Organisationen entdecken" opens no column; its content lives in the detail area
    const columns: TreeColumn[] = [{nodes: firstColumn(sportTree.data ?? [], organisations, !!user)}];
    livePath.forEach((node) => {
        const children = childNodes(node);
        if (children.length > 0) columns.push({nodes: children});
    });
    const selected = livePath[livePath.length - 1] ?? null;

    const handleClick = (node: TreeNode, level: number) => {
        setPath([...livePath.slice(0, level), node]);
        if (node.kind === "sport" && !node.organisation) {
            track("sport-select", {sport: node.label, level});
        }
    };

    const renderDetail = () => {
        if (!selected) return <SportDetailComponent id={""} title={""}/>;
        if (selected.kind === "discover") return <DiscoverOrganisationsPanel/>;
        const breadcrumb = livePath.slice(0, -1).map((node) => node.label);
        return <SportDetailComponent id={selected.id} title={selected.label} breadcrumb={breadcrumb}
                                     organisation={selected.organisation} key={selected.id}/>;
    };

    return (
        <div className="tree-columns">
            {columns.map((column, index) => (
                <div
                    key={index}
                    className="tree-column"
                    style={{background: columnColors[index] || "gray"}}
                >
                    {column.nodes.map((node) => {
                            const isOrganisationRoot = node.kind === "sport" && !!node.organisation && index === 0;
                            return (
                                <div
                                    key={node.id}
                                    className={`tree-item ${livePath[index]?.id === node.id ? "selected" : ""}`}
                                    onClick={() => handleClick(node, index)}
                                    style={node.kind === "discover" ? {borderBottom: "1px solid rgba(255,255,255,0.35)"} : undefined}
                                >
                                    <Flex style={{justifyContent: "space-between", alignItems: "center", padding: "1rem", width: "100%"}}>
                                        <Flex align={"center"} gap={8} style={{minWidth: 0}}>
                                            {isOrganisationRoot && <UsersThree size={16}/>}
                                            {node.kind === "discover" && <Compass size={16}/>}
                                            <h4 style={{fontStyle: node.kind === "discover" ? "italic" : undefined}}>{node.label}</h4>
                                        </Flex>
                                        {hasChildren(node) && <CaretRight size={10}/>}
                                    </Flex>
                                </div>
                            );
                        })}
                </div>
            ))}

            {renderDetail()}
        </div>
    );
}
