import "./style.css";
import ReactDOM from "react-dom/client";
import { Canvas } from "@react-three/fiber";
import Experience from "./Experience.jsx";

const root = ReactDOM.createRoot(document.querySelector("#root"));

root.render(
    <Canvas camera={{ position: [0, 0, 5], fov: 45 }}>
        <Experience />
    </Canvas>
);
