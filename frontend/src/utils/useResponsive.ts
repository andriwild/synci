import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";

/**
 * Breakpoint helper on top of antd's grid (xs < 576, sm >= 576, md >= 768, lg >= 992).
 *
 * - mobile  : < md   (accordion tree, hamburger menu, single column)
 * - tablet  : md..lg (column tree, no side panel)
 * - desktop : >= lg  (three panes)
 *
 * antd returns an empty object on the very first render; `ready` is false until the real
 * screen size is known so callers can avoid flashing the mobile variant on desktop.
 */
export const useResponsive = () => {
    const screens = useBreakpoint();
    const ready = screens.md !== undefined;
    return {
        ready,
        isMobile: ready && !screens.md,
        isTablet: !!screens.md && !screens.lg,
        isDesktop: !!screens.lg,
        /** < sm: phones in portrait */
        isXs: ready && !screens.sm,
        screens,
    };
};
