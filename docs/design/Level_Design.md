# ZED - Level Design Document
## Hand-Crafted Building Layouts for Tactical Extraction

ZED's level design philosophy centers on creating **learnable tactical environments** where map knowledge becomes a core player skill. Each building type features 3-4 carefully crafted layouts that players can master through repeated exposure, supporting the extraction shooter's emphasis on tactical positioning, route planning, and risk assessment.

## **Design Philosophy**

### **Map Knowledge as Progression**
Following Tarkov's proven approach, ZED treats **spatial knowledge as character advancement**. Players invest time learning optimal routes, memorizing loot spawns, and developing muscle memory for extraction paths. This creates a skill ceiling that rewards dedication and tactical thinking over reflexes alone.

### **Tactical Complexity Through Simplicity**
Each layout presents **multiple viable approaches** while maintaining clarity. Like Project Zomboid's building designs, rooms serve clear purposes with logical connections, but offer enough tactical variety to support different playstyles - aggressive clearing, stealth infiltration, or defensive positioning.

### **Risk-Reward Spatial Design**
High-value areas are positioned to require **tactical commitment**. Following Stalker Anomaly's design principles, the best loot is placed in locations that force players to expose themselves to danger, creating meaningful risk-reward decisions about route selection and engagement timing.

## **Hospital Complex - Primary Location**

### **Building Overview**
The Hospital represents ZED's most tactically complex environment, featuring multi-story layouts with interconnected departments, emergency systems, and high-value medical supplies. Drawing inspiration from Project Zomboid's medical facilities and Tarkov's multi-level complexity, the Hospital rewards both aggressive clearing and careful reconnaissance.

### **Layout Variants**

#### **Variant A: Regional Medical Center**
**Tactical Theme**: Vertical complexity with chokepoint control

**Ground Floor Layout**:
- **Emergency Department** - Large open triage area with multiple entrances
- **Reception/Waiting** - Central hub with sight lines to multiple departments  
- **Pharmacy** - High-value target requiring key card access
- **Radiology Wing** - Narrow corridors with equipment providing cover
- **Main Stairwell** - Central vertical access point, high zombie density

**Second Floor Layout**:
- **Surgical Suites** - Multiple small rooms with valuable medical equipment
- **ICU Ward** - Long corridor with patient rooms, multiple extraction routes
- **Medical Storage** - Locked area with rare pharmaceutical supplies
- **Staff Areas** - Break rooms and offices with basic supplies
- **Emergency Stairwell** - Secondary vertical access, often locked

**Tactical Considerations**:
- **Chokepoint Control**: Stairwells become critical tactical positions
- **Vertical Threat Management**: Zombies can pursue between floors
- **Multiple Extraction Options**: Emergency exits on both floors
- **Key Card Progression**: Pharmacy and storage require found access cards

#### **Variant B: Community Hospital**
**Tactical Theme**: Horizontal sprawl with department isolation

**Single Floor Layout**:
- **Main Entrance** - Controlled access with security checkpoint
- **Emergency Bay** - Vehicle access with multiple zombie spawn points
- **Patient Wards** - East and West wings with connecting corridors
- **Central Nursing Station** - Elevated position with sight lines to both wings
- **Laboratory** - Isolated section requiring separate access route
- **Morgue** - Underground access with unique zombie variants

**Tactical Considerations**:
- **Wing Isolation**: Clear one section before moving to next
- **Central Overwatch**: Nursing station provides tactical advantage
- **Flanking Routes**: Multiple paths between departments
- **Environmental Hazards**: Medical equipment can be used tactically

#### **Variant C: Trauma Center**
**Tactical Theme**: Emergency response layout with rapid access routes

**Compact Layout**:
- **Trauma Bays** - Open treatment areas with mobile equipment cover
- **Fast Track** - Direct route from entrance to critical areas
- **Supply Central** - Heavily stocked but well-defended storage
- **Helipad Access** - Rooftop extraction point requiring vertical movement
- **Basement Utilities** - Power systems and maintenance tunnels

**Tactical Considerations**:
- **Speed vs. Stealth**: Fast Track allows rapid movement but high exposure
- **Vertical Extraction**: Helipad requires clearing multiple levels
- **Power Control**: Basement access affects lighting and security systems
- **Equipment Mobility**: Medical carts can be repositioned for cover

### **Dynamic Mission Elements**

#### **Randomized Access States**
- **Department Locks**: 40% of departments locked each mission
- **Emergency Power**: Affects lighting and electronic doors
- **Quarantine Protocols**: Some areas sealed with higher zombie density
- **Evacuation Routes**: 2-3 extraction points active per mission

#### **Loot Distribution Logic**
- **Pharmacy**: High-value pharmaceuticals, requires key card access
- **Surgical Suites**: Sterile medical supplies, surgical instruments
- **Patient Rooms**: Basic medical supplies, personal items
- **Storage Areas**: Bulk medical supplies, equipment parts
- **Staff Areas**: Food, basic supplies, key cards

#### **Threat Scaling**
- **Zombie Density**: Higher in patient areas, lower in administrative zones
- **Special Infected**: Medical zombies with unique behaviors in surgical areas
- **Environmental Hazards**: Medical gas leaks, electrical hazards
- **Time Pressure**: Hospital backup power creates escalating threat

## **Tactical Design Principles**

### **Sight Line Management**
Following Tarkov's approach to tactical positioning:

**Long Corridors**: Patient ward hallways create sniper-like engagements requiring precision shooting and ammunition conservation.

**Corner Clearing**: Each room entry requires tactical approach with multiple potential threat angles.

**Elevation Advantage**: Second-floor positions provide overwatch opportunities but limit escape routes.

**Cover Density**: Medical equipment, gurneys, and furniture provide tactical positioning options without cluttering movement.

### **Route Complexity**
Inspired by Project Zomboid's interconnected building design:

**Primary Routes**: Main corridors allow rapid movement but high exposure to threats.

**Secondary Paths**: Service corridors and maintenance areas provide stealth options with limited loot access.

**Emergency Routes**: Fire exits and emergency stairwells offer extraction options but may be locked or alarmed.

**Vertical Movement**: Stairwells become critical tactical positions requiring careful clearing.

### **Resource Distribution Strategy**
Based on Stalker Anomaly's risk-reward placement:

**High-Value Concentration**: Best medical supplies in pharmacy and surgical areas requiring tactical commitment.

**Scattered Basic Supplies**: Patient rooms provide steady resource income with manageable risk.

**Emergency Caches**: Hidden supplies in maintenance areas reward exploration and map knowledge.

**Progressive Access**: Key cards and access codes gate premium areas, creating mission progression.

## **Player Learning Progression**

### **Novice Phase (Missions 1-5)**
- **Layout Familiarization**: Learn basic room connections and primary routes
- **Threat Identification**: Understand zombie spawn patterns and density areas
- **Resource Location**: Discover reliable loot spawns and basic supply areas
- **Extraction Recognition**: Identify and practice using different exit routes

### **Intermediate Phase (Missions 6-15)**
- **Route Optimization**: Develop efficient clearing patterns and movement sequences
- **Risk Assessment**: Learn when to engage vs. avoid based on resource levels
- **Tactical Positioning**: Master cover usage and sight line control
- **Key Card Management**: Understand access progression and priority targets

### **Expert Phase (Missions 16+)**
- **Speed Running**: Execute rapid clearing for time-sensitive objectives
- **Resource Efficiency**: Maximize loot collection while minimizing risk exposure
- **Adaptive Tactics**: Adjust strategy based on mission parameters and threat levels
- **Teaching Others**: In multiplayer, guide less experienced players through layouts

## **Integration with Core Mechanics**

### **Permadeath Considerations**
- **Multiple Extraction Routes**: Ensure players always have escape options
- **Progressive Risk Areas**: Allow conservative players to avoid high-danger zones
- **Recovery Opportunities**: Provide healing and resupply points throughout facility
- **Clear Threat Indicators**: Visual and audio cues warn of dangerous areas

### **Resource Management Support**
- **Ammunition Conservation**: Design encourages tactical shooting over spray-and-pray
- **Medical Supply Logic**: Realistic placement supports immersion and strategic planning
- **Equipment Durability**: Environmental hazards create gear degradation pressure
- **Time Pressure**: Layout supports both speed clearing and methodical approaches

### **Base Development Integration**
- **Progressive Unlocks**: Advanced hospital areas require base upgrades to access
- **Intelligence Gathering**: Reconnaissance missions provide layout information
- **Equipment Requirements**: Specialized gear needed for certain hospital areas
- **Skill Development**: Medical knowledge affects loot identification and usage

## **Technical Implementation Guidelines**

### **Performance Optimization**
- **Room-Based Loading**: Stream hospital sections as players move through facility
- **Occlusion Culling**: Use walls and doors to hide non-visible areas
- **Entity Density Management**: Limit active zombies per room while maintaining threat level

### **Modular Construction**
- **Room Templates**: Standardized room sizes for efficient development
- **Connector Systems**: Flexible hallway and door placement for variant creation
- **Asset Reuse**: Common medical equipment and furniture across all variants

### **Debug and Testing Support**
- **Layout Visualization**: Debug mode shows all rooms and connections
- **Spawn Point Testing**: Validate zombie and loot placement across variants
- **Route Analysis**: Track player movement patterns to identify design issues

## **Future Expansion Framework**

### **Additional Hospital Variants**
- **Psychiatric Wing**: Unique zombie behaviors and environmental storytelling
- **Research Facility**: High-tech equipment and experimental medical supplies
- **Field Hospital**: Military medical setup with different tactical challenges

### **Cross-Building Connections**
- **Underground Tunnels**: Connect hospital to other city buildings
- **Emergency Networks**: Shared communication and power systems
- **Evacuation Routes**: Multi-building extraction sequences

### **Seasonal and Event Modifications**
- **Power Outages**: Darkness affects visibility and zombie behavior
- **Quarantine Events**: Increased zombie density and locked areas
- **Supply Drops**: Temporary high-value loot with increased competition

---

This Level Design Document establishes the foundation for ZED's tactical extraction gameplay, ensuring that each hospital mission provides meaningful choices, learnable complexity, and escalating mastery requirements that reward dedicated players while remaining accessible to newcomers.
