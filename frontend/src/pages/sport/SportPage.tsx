import {FC, useState} from "react";
import {SportTreeComponent} from "./desktop/SportTreeComponent.tsx";
import {SyncConfigComponent} from "./desktop/SyncConfigComponent.tsx";
import "./SportPage.css";
import {SportTreeMobileComponent} from "./mobile/SportTreeMobileComponent.tsx";
import {useResponsive} from "../../utils/useResponsive.ts";
import {SyncConfigBar, SyncConfigDrawer} from "./mobile/SyncConfigDrawer.tsx";

/**
 * < md : accordion tree, subscription in a bottom drawer
 * md-lg: column tree, subscription in a bottom drawer
 * >= lg: column tree with the subscription side panel
 */
export const SportPage: FC = () => {
    const {ready, isMobile, isDesktop} = useResponsive();
    const [drawerOpen, setDrawerOpen] = useState(false);

    if (!ready) {
        return <div className="sport-layout"/>;
    }

    return (
        <div className="sport-layout">
            <div className="sport-main">
                <div className="sport-tree-panel">
                    {isMobile ? <SportTreeMobileComponent/> : <SportTreeComponent/>}
                </div>
                {!isDesktop && <SyncConfigBar onOpen={() => setDrawerOpen(true)}/>}
            </div>
            {isDesktop
                ? <aside className="sport-sidebar"><SyncConfigComponent/></aside>
                : <SyncConfigDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)}/>}
        </div>
    );
};
