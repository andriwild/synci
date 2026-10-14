import {FC} from "react";
import {SportTreeComponent} from "./desktop/SportTreeComponent.tsx";
import "./SportPage.css";
import {SportTreeMobileComponent} from "./mobile/SportTreeMobileComponent.tsx";
import {useResponsive} from "../../utils/useResponsive.ts";
import {SyncConfigFab} from "./shared-components/SyncConfigFab.tsx";

/**
 * Tree and detail use the full width (accordion below md, column tree above).
 * The subscription lives behind a floating button in the bottom right corner.
 */
export const SportPage: FC = () => {
    const {ready, isMobile} = useResponsive();

    if (!ready) {
        return <div className="sport-layout"/>;
    }

    return (
        <div className="sport-layout">
            <div className="sport-tree-panel">
                {isMobile ? <SportTreeMobileComponent/> : <SportTreeComponent/>}
            </div>
            <SyncConfigFab/>
        </div>
    );
};
