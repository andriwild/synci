import {theme, Typography} from "antd";
import {track} from "../../../utils/analytics.ts";
import {APP_STORE_URL, PLAY_STORE_URL} from "../../../utils/storeLinks.ts";

/** the iPhone and Android app with both store badges and the app's start screen */
export const AppPromoComponent = () => {
    const {token} = theme.useToken();

    return (
        <section style={{background: token.colorBgBase, padding: "clamp(32px, 6vw, 60px) 0"}}
                 aria-labelledby="app-promo-title">
            <div className={"container"}>
                <div className="app-promo">
                    <div className="app-promo__text">
                        <Typography.Title level={2} id="app-promo-title" style={{fontWeight: 400, margin: 0}}>
                            Synci gibt’s auch als App
                        </Typography.Title>
                        <Typography.Text style={{maxWidth: "520px"}}>
                            Entdecke Ligen, Teams und Events, verwalte deine Abos und übernimm sie mit einem Tipp in
                            deinen Kalender. Kostenlos für iPhone und Android.
                        </Typography.Text>
                        <div className="app-promo__badges">
                            <a href={APP_STORE_URL} target="_blank" rel="noopener"
                               onClick={() => track("app-store-click", {store: "apple"})}>
                                <img src="/assets/badges/app-store-de.svg" alt="Laden im App Store" width={150}
                                     height={50}/>
                            </a>
                            <a href={PLAY_STORE_URL} target="_blank" rel="noopener"
                               onClick={() => track("app-store-click", {store: "google"})}>
                                <img src="/assets/badges/google-play-de.png" alt="Jetzt bei Google Play" width={168}
                                     height={50}/>
                            </a>
                        </div>
                    </div>
                    <div className="app-promo__phone">
                        <img src="/assets/images/app-start-screen.webp"
                             alt="Startseite der Synci-App mit Sportarten und Vereinen" width={600} height={1304}
                             loading="lazy"/>
                    </div>
                </div>
            </div>
        </section>
    );
}
