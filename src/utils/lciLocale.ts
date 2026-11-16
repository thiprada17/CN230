import type { ProductRecord } from '../types/lci';

const productNames: Record<string, string> = {
  'Organic Hom Mali paddy rice (KDML 105)': 'ข้าวเปลือกหอมมะลิอินทรีย์ (ขาวดอกมะลิ 105)',
  'Thai wet-season rice (national statistics)': 'ข้าวนาปีระดับประเทศ',
  'Thai dry-season rice (national statistics)': 'ข้าวนาปรังระดับประเทศ',
  'Milled Hom Mali rice': 'ข้าวหอมมะลิขัดสี',
  'Broken rice': 'ปลายข้าว',
  'Withered rice': 'ข้าวลีบ',
  'Rice bran': 'รำข้าว',
  'Rice husk': 'แกลบ',
  'Thai white rice 5% (national milling reference)': 'ข้าวขาวไทย 5% (ค่าอ้างอิงระดับประเทศ)',
  'Thai paddy rice (national milling reference)': 'ข้าวเปลือกไทย (ค่าอ้างอิงระดับประเทศ)',
  'Native tapioca starch (0% water content)': 'แป้งมันสำปะหลังดิบ (ความชื้น 0%)',
  'Fresh cassava root': 'หัวมันสำปะหลังสด',
  'Cassava peel (dry basis)': 'เปลือกมันสำปะหลัง (น้ำหนักแห้ง)',
  'Cassava pulp (dry basis)': 'กากมันสำปะหลัง (น้ำหนักแห้ง)',
  'Maize cob': 'ซังข้าวโพด',
  'Maize residue (leaves and stalks)': 'เศษซากข้าวโพด (ใบและลำต้น)',
  'Maize grain': 'เมล็ดข้าวโพด',
  Sugarcane: 'อ้อย',
  Sugar: 'น้ำตาล',
  Bagasse: 'ชานอ้อย',
  Molasses: 'กากน้ำตาล',
  'Filter cake': 'กากตะกอนหม้อกรอง',
  'Pineapple (fresh)': 'สับปะรดสด',
  'Canned pineapple (30 oz.)': 'สับปะรดกระป๋อง (30 ออนซ์)',
  'Pineapple processing residues (stems and crowns)': 'เศษเหลือสับปะรด (ลำต้นและจุก)',
  'Pineapple peel': 'เปลือกสับปะรด',
  'Pineapple core': 'แกนสับปะรด',
  'Pineapple feedstock for processing (national estimate)': 'วัตถุดิบสับปะรดสำหรับแปรรูป (ประมาณการระดับประเทศ)',
};

const descriptions: Record<string, string> = {
  'National annual wet-season rice production series. Production statistics only; not a complete life-cycle inventory.': 'ชุดข้อมูลผลผลิตข้าวนาปีระดับประเทศรายปี เป็นข้อมูลสถิติผลผลิต ไม่ใช่ข้อมูลวัฏจักรชีวิตครบทุกขั้นตอน',
  'National annual dry-season rice production series. Production statistics only; not a complete life-cycle inventory.': 'ชุดข้อมูลผลผลิตข้าวนาปรังระดับประเทศรายปี เป็นข้อมูลสถิติผลผลิต ไม่ใช่ข้อมูลวัฏจักรชีวิตครบทุกขั้นตอน',
  'Organic Hom Mali paddy rice studied in Thailand': 'ข้อมูลการผลิตข้าวเปลือกหอมมะลิอินทรีย์ที่ศึกษาในประเทศไทย',
  'Whole milled rice product; no production quantity loaded yet': 'ข้าวสารเต็มเมล็ดจากการสีข้าว ยังไม่มีข้อมูลปริมาณการผลิต',
  'Broken rice fraction from milling; no production quantity loaded yet': 'ปลายข้าวที่ได้จากการสี ยังไม่มีข้อมูลปริมาณการผลิต',
  'Withered rice fraction reported in the KDML 105 milling study': 'ข้าวลีบที่รายงานในการศึกษาการสีข้าวขาวดอกมะลิ 105',
  'Rice bran by-product from milling': 'รำข้าวที่ได้เป็นผลพลอยได้จากการสี',
  'Rice husk by-product from husking': 'แกลบที่ได้เป็นผลพลอยได้จากการกะเทาะเปลือก',
  '5% white rice output from the national average milling-yield table in UNIDO (1980), Table 14B.': 'ผลผลิตข้าวขาว 5% จากตารางผลได้เฉลี่ยการสีข้าวระดับประเทศของ UNIDO (1980) ตาราง 14B',
  'Generic Thai paddy rice used as the input to the national milling-yield reference; not specific to Hom Mali.': 'ข้าวเปลือกไทยทั่วไปที่ใช้เป็นวัตถุดิบในค่าอ้างอิงการสีระดับประเทศ ไม่ได้เจาะจงข้าวหอมมะลิ',
  'Main product; reference functional unit is 1,000 kg at 0% water content': 'ผลิตภัณฑ์หลัก โดยหน่วยหน้าที่อ้างอิงคือแป้ง 1,000 กก. ที่ความชื้น 0%',
  'Raw agricultural commodity; no fresh-weight production quantity added from this factory inventory': 'ผลผลิตทางการเกษตรดิบ ชุดข้อมูลโรงงานนี้ไม่ได้ระบุปริมาณหัวมันสด',
  'Processing by-product; quantity reported on a dry basis': 'ผลพลอยได้จากกระบวนการแปรรูป รายงานปริมาณในรูปน้ำหนักแห้ง',
  'Agricultural co-product reported per hectare': 'ผลผลิตร่วมทางการเกษตร รายงานต่อพื้นที่ 1 เฮกตาร์',
  'Main crop product; yield reported per hectare': 'ผลผลิตหลักของพืช รายงานผลผลิตต่อพื้นที่ 1 เฮกตาร์',
  'Harvested sugarcane; yield reported as 58 tonnes per hectare and converted to 58,000 kg per hectare.': 'อ้อยที่เก็บเกี่ยว รายงานผลผลิต 58 ตันต่อเฮกตาร์ หรือ 58,000 กก.ต่อเฮกตาร์',
  'Sugarcane milling co-product; reported mass is 231 kg per 1,000 kg harvested sugarcane.': 'ผลผลิตร่วมจากการหีบอ้อย รายงาน 231 กก.ต่ออ้อยที่เก็บเกี่ยว 1,000 กก.',
  'Sugarcane milling co-product; reported mass is 26 kg per 1,000 kg harvested sugarcane.': 'ผลผลิตร่วมจากการหีบอ้อย รายงาน 26 กก.ต่ออ้อยที่เก็บเกี่ยว 1,000 กก.',
  'Raw sugarcane filter cake (press mud), before any further treatment; 33 kg per 1,000 kg harvested sugarcane.': 'กากตะกอนจากการกรองน้ำอ้อยก่อนบำบัดเพิ่มเติม รายงาน 33 กก.ต่ออ้อยที่เก็บเกี่ยว 1,000 กก.',
  'Fresh Smooth Cayenne pineapple; cultivation inventory from three farm-size scenarios.': 'สับปะรดพันธุ์ปัตตาเวียสด ข้อมูลการเพาะปลูกจากฟาร์ม 3 ขนาด',
  'Canned pineapple with net weight 30 oz.; functional unit used in the 2017 study.': 'สับปะรดกระป๋องน้ำหนักสุทธิ 30 ออนซ์ ตามหน่วยหน้าที่ในการศึกษาปี 2017',
  'Combined pineapple stems (4.6%) and crowns (4.3%); grouped as other processing residues to avoid double counting.': 'รวมลำต้นสับปะรด (4.6%) และจุก (4.3%) เป็นเศษเหลืออื่นจากการแปรรูป เพื่อป้องกันการนับซ้ำ',
  'Pineapple peel by-product; approximately 35.5% of processing feedstock in Hemung et al. (2022).': 'เปลือกสับปะรดซึ่งเป็นผลพลอยได้ คิดเป็นประมาณ 35.5% ของวัตถุดิบแปรรูป ตาม Hemung et al. (2022)',
  'Pineapple core by-product; approximately 14.7% of processing feedstock in Hemung et al. (2022).': 'แกนสับปะรดซึ่งเป็นผลพลอยได้ คิดเป็นประมาณ 14.7% ของวัตถุดิบแปรรูป ตาม Hemung et al. (2022)',
  'National annual pineapple quantity used as the reference basis for the 2020 by-product estimate.': 'ปริมาณสับปะรดรายปีระดับประเทศที่ใช้เป็นฐานประมาณการผลพลอยได้ในปี 2020',
};

export const categories: Record<string, string> = {
  'National rice statistics': 'สถิติข้าวระดับประเทศ',
  'Organic rice': 'ข้าวอินทรีย์',
  'Milled rice and rice by-products': 'ข้าวสารและผลพลอยได้จากการสี',
  'Rice milling reference': 'ข้อมูลอ้างอิงการสีข้าว',
  'Cassava and tapioca starch products': 'มันสำปะหลังและแป้งมัน',
  'Maize and maize residues': 'ข้าวโพดและเศษเหลือ',
  'Sugarcane and sugar products': 'อ้อยและผลิตภัณฑ์น้ำตาล',
  'Pineapple and pineapple products': 'สับปะรดและผลิตภัณฑ์',
};

const locations: Record<string, string> = {
  'Thailand (national statistics)': 'ประเทศไทย (ข้อมูลสถิติระดับประเทศ)',
  Surin: 'สุรินทร์',
  'Not specified': 'ไม่ระบุพื้นที่',
  'Unknown province': 'ไม่ระบุจังหวัด',
  'Northeast Thailand (Regional Average)': 'ภาคตะวันออกเฉียงเหนือ (ค่าเฉลี่ยระดับภูมิภาค)',
  'Thailand (National Milling Reference)': 'ประเทศไทย (ข้อมูลอ้างอิงการสีระดับประเทศ)',
  'Northeast Thailand (factory case study; province not specified)': 'ภาคตะวันออกเฉียงเหนือ (กรณีศึกษาโรงงาน ไม่ระบุจังหวัด)',
  'Northern Thailand (Weighted Average)': 'ภาคเหนือ (ค่าเฉลี่ยถ่วงน้ำหนัก)',
  'Chiang Mai': 'เชียงใหม่',
  'Thailand (15-factory contract-farmer aggregate)': 'ประเทศไทย (ค่าเฉลี่ยเกษตรกรคู่สัญญา 15 โรงงาน)',
  'Central Thailand (25-farm pineapple study)': 'ภาคกลาง (การศึกษาฟาร์มสับปะรด 25 แห่ง)',
  'Central Thailand (canning factory case study)': 'ภาคกลาง (กรณีศึกษาโรงงานบรรจุกระป๋อง)',
  'Thailand (national pineapple-processing estimate)': 'ประเทศไทย (ประมาณการแปรรูปสับปะรดระดับประเทศ)',
  'Thailand (national sugarcane industry reference)': 'ประเทศไทย (ข้อมูลอ้างอิงอุตสาหกรรมอ้อยระดับประเทศ)',
};

const processSteps: Record<string, string> = {
  'Aggregated milling yield (Table 14B)': 'ผลได้รวมจากการสีข้าว (ตาราง 14B)',
  'Aggregated starch production': 'การผลิตแป้งมันสำปะหลังโดยรวม',
  'Canning and packaging (one 30 oz. can)': 'การบรรจุกระป๋องและบรรจุภัณฑ์ (กระป๋อง 30 ออนซ์)',
  'Cassava field cultivation': 'การเพาะปลูกมันสำปะหลัง',
  'Cleaning and pre-treatment': 'การทำความสะอาดและเตรียมวัตถุดิบ',
  'Cultivation and harvesting': 'การเพาะปลูกและเก็บเกี่ยว',
  'Cultivation (whole crop-cycle inventory)': 'การเพาะปลูกตลอดรอบการผลิต',
  Farming: 'การทำเกษตร',
  'Field preparation': 'การเตรียมพื้นที่',
  Harvesting: 'การเก็บเกี่ยว',
  'Harvesting and cleaning': 'การเก็บเกี่ยวและทำความสะอาด',
  'Harvesting and milling': 'การเก็บเกี่ยวและหีบอ้อย',
  Husking: 'การกะเทาะเปลือก',
  'Land preparation': 'การเตรียมพื้นที่เพาะปลูก',
  Planting: 'การปลูก',
  'Post harvesting (open burning)': 'หลังการเก็บเกี่ยว (การเผาในที่โล่ง)',
  'Separation of pineapple processing by-products': 'การแยกผลพลอยได้จากการแปรรูปสับปะรด',
  'Small-machine milling at 12.1% paddy moisture': 'การสีด้วยเครื่องขนาดเล็ก ที่ความชื้นข้าวเปลือก 12.1%',
  'Soil preparation': 'การเตรียมดิน',
  'Sugarcane cultivation (1 hectare)': 'การเพาะปลูกอ้อย (1 เฮกตาร์)',
  'Sugar milling and co-product generation': 'การหีบอ้อยและการเกิดผลผลิตร่วม',
  'Sugar production (per 1 kg sugar)': 'การผลิตน้ำตาล (ต่อน้ำตาล 1 กก.)',
  'Transportation of 58 tonnes of sugarcane': 'การขนส่งอ้อย 58 ตัน',
  Weeding: 'การกำจัดวัชพืช',
  Whitening: 'การขัดขาว',
  'Whole-system LCI - ecoinvent v3.0 (functional unit: 1 kg maize grain)': 'บัญชีวัฏจักรชีวิตทั้งระบบ - ecoinvent v3.0 (หน่วยหน้าที่: เมล็ดข้าวโพด 1 กก.)',
  'Whole-system LCI - IDEA v2.0 (functional unit: 1 kg maize grain)': 'บัญชีวัฏจักรชีวิตทั้งระบบ - IDEA v2.0 (หน่วยหน้าที่: เมล็ดข้าวโพด 1 กก.)',
};

const exactFlowNames: Record<string, string> = {
  'Other flows': 'รายการอื่น',
  'CO2 (ecoinvent v3.0)': 'คาร์บอนไดออกไซด์ (ecoinvent v3.0)',
  'CO2 (IDEA v2.0)': 'คาร์บอนไดออกไซด์ (IDEA v2.0)',
  'Coal (ecoinvent v3.0)': 'ถ่านหิน (ecoinvent v3.0)',
  'Coal (IDEA v2.0)': 'ถ่านหิน (IDEA v2.0)',
  'Natural gas (ecoinvent v3.0)': 'ก๊าซธรรมชาติ (ecoinvent v3.0)',
  'Natural gas (IDEA v2.0)': 'ก๊าซธรรมชาติ (IDEA v2.0)',
  'Oil (ecoinvent v3.0)': 'น้ำมัน (ecoinvent v3.0)',
  'Oil (IDEA v2.0)': 'น้ำมัน (IDEA v2.0)',
  'NOx (ecoinvent v3.0)': 'ออกไซด์ของไนโตรเจน (ecoinvent v3.0)',
  'NOx (IDEA v2.0)': 'ออกไซด์ของไนโตรเจน (IDEA v2.0)',
  'SO2 (ecoinvent v3.0)': 'ซัลเฟอร์ไดออกไซด์ (ecoinvent v3.0)',
  'SO2 (IDEA v2.0)': 'ซัลเฟอร์ไดออกไซด์ (IDEA v2.0)',
  'PM2.5 (ecoinvent v3.0)': 'ฝุ่นละออง PM2.5 (ecoinvent v3.0)',
  'PM2.5 (IDEA v2.0)': 'ฝุ่นละออง PM2.5 (IDEA v2.0)',
  'Sugarcane cleaning waste (Makul & Sua-iam 2016 reference)': 'เศษเหลือจากการทำความสะอาดอ้อย (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Sugarcane delivered to factory (Makul & Sua-iam 2016 reference)': 'อ้อยที่ส่งถึงโรงงาน (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Sugarcane field waste (Makul & Sua-iam 2016 reference)': 'เศษเหลือในไร่อ้อย (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Sugarcane received by mill (Makul & Sua-iam 2016 reference)': 'อ้อยที่โรงงานรับเข้า (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Sugar (Makul & Sua-iam 2016 reference)': 'น้ำตาล (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Thai paddy rice (national milling reference)': 'ข้าวเปลือกไทย (ค่าอ้างอิงการสีระดับประเทศ)',
  'Thai white rice 5% (national milling reference)': 'ข้าวขาวไทย 5% (ค่าอ้างอิงการสีระดับประเทศ)',
  'Total suspended particulates (sugar production)': 'ฝุ่นแขวนลอยทั้งหมด (การผลิตน้ำตาล)',
  'Total dissolved solids (sugar production)': 'ของแข็งละลายทั้งหมด (การผลิตน้ำตาล)',
  'Total nitrogen': 'ไนโตรเจนทั้งหมด',
  'Total phosphorus': 'ฟอสฟอรัสทั้งหมด',
  Alachlor: 'อะลาคลอร์', Ametine: 'อะเมทรีน', Atrazine: 'อะทราซีน',
  'Bagasse (Makul & Sua-iam 2016 reference)': 'ชานอ้อย (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Biochemical oxygen demand (sugar production)': 'ความต้องการออกซิเจนทางชีวเคมี (การผลิตน้ำตาล)',
  'Broken rice': productNames['Broken rice'],
  'Calcium carbide (pineapple cultivation)': 'แคลเซียมคาร์ไบด์ (การเพาะปลูกสับปะรด)',
  'Canned pineapple (30 oz.)': productNames['Canned pineapple (30 oz.)'],
  'Carbon dioxide (fossil fuel combustion)': 'คาร์บอนไดออกไซด์ (การเผาไหม้เชื้อเพลิงฟอสซิล)',
  'Carbon dioxide (sugarcane cultivation)': 'คาร์บอนไดออกไซด์ (การเพาะปลูกอ้อย)',
  'Carbon dioxide (sugarcane transportation)': 'คาร์บอนไดออกไซด์ (การขนส่งอ้อย)',
  'Carbon dioxide (sugar production)': 'คาร์บอนไดออกไซด์ (การผลิตน้ำตาล)',
  'Carbon monoxide (fossil fuel combustion)': 'คาร์บอนมอนอกไซด์ (การเผาไหม้เชื้อเพลิงฟอสซิล)',
  'Carbon monoxide (sugar production)': 'คาร์บอนมอนอกไซด์ (การผลิตน้ำตาล)',
  'Cardboard (pineapple processing)': 'กระดาษลัง (การแปรรูปสับปะรด)',
  'Cassava peel (dry basis)': productNames['Cassava peel (dry basis)'],
  'Cassava pulp (dry basis)': productNames['Cassava pulp (dry basis)'],
  'Cassava root (dry basis)': 'รากมันสำปะหลัง (น้ำหนักแห้ง)',
  'Chemical oxygen demand (sugar production)': 'ความต้องการออกซิเจนทางเคมี (การผลิตน้ำตาล)',
  'Chemicals (sugar production)': 'สารเคมี (การผลิตน้ำตาล)',
  'Chicken manure fertilizer (pineapple cultivation)': 'ปุ๋ยมูลไก่ (การเพาะปลูกสับปะรด)',
  Compost: 'ปุ๋ยหมัก', Diesel: 'น้ำมันดีเซล',
  'Diesel (pineapple cultivation)': 'น้ำมันดีเซล (การเพาะปลูกสับปะรด)',
  'Diesel (sugar production)': 'น้ำมันดีเซล (การผลิตน้ำตาล)',
  'Electricity (pineapple processing)': 'ไฟฟ้า (การแปรรูปสับปะรด)',
  'Ethephon (pineapple cultivation)': 'เอทีฟอน (การเพาะปลูกสับปะรด)',
  'Fertilizer bag': 'ถุงบรรจุปุ๋ย',
  'Filter cake (Makul & Sua-iam 2016 reference)': 'กากตะกอนหม้อกรอง (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Fresh cassava root': productNames['Fresh cassava root'],
  'Fresh pineapple (canned production input)': 'สับปะรดสด (วัตถุดิบสำหรับผลิตสับปะรดกระป๋อง)',
  'Fresh pineapple (cultivation output)': 'สับปะรดสด (ผลผลิตจากการเพาะปลูก)',
  'Fresh water': 'น้ำจืด', 'Fuel oil': 'น้ำมันเตา',
  'Fuel oil (sugar production)': 'น้ำมันเตา (การผลิตน้ำตาล)',
  'Gasoline (pineapple cultivation)': 'น้ำมันเบนซิน (การเพาะปลูกสับปะรด)',
  'Grid electricity': 'ไฟฟ้าจากระบบสายส่ง',
  'Harvested sugarcane (Makul & Sua-iam 2016 reference)': 'อ้อยที่เก็บเกี่ยว (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'Herbicide (pineapple cultivation)': 'สารกำจัดวัชพืช (การเพาะปลูกสับปะรด)',
  'Hom Mali paddy rice (12.1% moisture) - Khomkaew 2022': 'ข้าวเปลือกหอมมะลิ (ความชื้น 12.1%) - Khomkaew, 2022',
  'Hydrogen chloride (sugar production)': 'ไฮโดรเจนคลอไรด์ (การผลิตน้ำตาล)',
  'Insecticide (pineapple cultivation)': 'สารกำจัดแมลง (การเพาะปลูกสับปะรด)',
  'Land occupation (ecoinvent v3.0)': 'การใช้พื้นที่ดิน (ecoinvent v3.0)',
  'Land occupation (IDEA v2.0)': 'การใช้พื้นที่ดิน (IDEA v2.0)',
  'Land transformation (ecoinvent v3.0)': 'การเปลี่ยนแปลงการใช้ที่ดิน (ecoinvent v3.0)',
  'Land transformation (IDEA v2.0)': 'การเปลี่ยนแปลงการใช้ที่ดิน (IDEA v2.0)',
  'Liquid waste from sugar milling (Makul & Sua-iam 2016 reference)': 'ของเสียเหลวจากการหีบอ้อย (ข้อมูลอ้างอิง Makul และ Sua-iam, 2016)',
  'LPG (pineapple cultivation)': 'ก๊าซปิโตรเลียมเหลว (การเพาะปลูกสับปะรด)',
  'LPG (sugar production)': 'ก๊าซปิโตรเลียมเหลว (การผลิตน้ำตาล)',
  'Maize cob': productNames['Maize cob'], 'Maize grain': productNames['Maize grain'],
  'Maize residue (leaves and stalks)': productNames['Maize residue (leaves and stalks)'],
  'Maize seed': 'เมล็ดพันธุ์ข้าวโพด',
  'Manure (green and cattle)': 'ปุ๋ยคอก (พืชสดและมูลโค)',
  'Methane (fossil fuel combustion)': 'มีเทน (การเผาไหม้เชื้อเพลิงฟอสซิล)',
  'Methane (rice field)': 'มีเทน (นาข้าว)',
  'Methane (sugarcane transportation)': 'มีเทน (การขนส่งอ้อย)',
  'Methane (sugar production)': 'มีเทน (การผลิตน้ำตาล)',
  'Milled Hom Mali rice': productNames['Milled Hom Mali rice'],
  'Native tapioca starch (0% water content)': productNames['Native tapioca starch (0% water content)'],
  'Nitrogen fertilizer (pineapple cultivation)': 'ปุ๋ยไนโตรเจน (การเพาะปลูกสับปะรด)',
  'Nitrogen (nutrient)': 'ไนโตรเจน (ธาตุอาหาร)',
  'Nitrogen oxides (sugar production)': 'ออกไซด์ของไนโตรเจน (การผลิตน้ำตาล)',
  'Nitrous oxide (direct)': 'ไนตรัสออกไซด์ (การปล่อยโดยตรง)',
  'Nitrous oxide (fossil fuel combustion)': 'ไนตรัสออกไซด์ (การเผาไหม้เชื้อเพลิงฟอสซิล)',
  'Nitrous oxide (indirect volatilization)': 'ไนตรัสออกไซด์ (การระเหยทางอ้อม)',
  'Nitrous oxide (leaching and runoff)': 'ไนตรัสออกไซด์ (การชะล้างและน้ำไหลบ่า)',
  'Nitrous oxide (sugarcane cultivation)': 'ไนตรัสออกไซด์ (การเพาะปลูกอ้อย)',
  'Nitrous oxide (sugarcane transportation)': 'ไนตรัสออกไซด์ (การขนส่งอ้อย)',
  'Nitrous oxide (sugar production)': 'ไนตรัสออกไซด์ (การผลิตน้ำตาล)',
  'Non-methane volatile organic compounds (fossil fuel combustion)': 'สารอินทรีย์ระเหยง่ายที่ไม่มีมีเทน (การเผาไหม้เชื้อเพลิงฟอสซิล)',
  'NPK fertilizer (15-15-15)': 'ปุ๋ย NPK (15-15-15)',
  'Organic fertilizer': 'ปุ๋ยอินทรีย์',
  'Organic fertilizer (liquid)': 'ปุ๋ยอินทรีย์ (ชนิดน้ำ)',
  'Organic fertilizer (pellet)': 'ปุ๋ยอินทรีย์ (ชนิดเม็ด)',
  'Organic fertilizer (pellet and liquid)': 'ปุ๋ยอินทรีย์ (ชนิดเม็ดและชนิดน้ำ)',
  'Organic Hom Mali paddy rice (KDML 105)': productNames['Organic Hom Mali paddy rice (KDML 105)'],
  'Paraquat dichloride (kg)': 'พาราควอตไดคลอไรด์ (กก.)',
  'Paraquat dichloride (L)': 'พาราควอตไดคลอไรด์ (ลิตร)',
  'Pesticides (aggregate)': 'สารกำจัดศัตรูพืช (รวม)',
  'Phosphorus fertilizer (pineapple cultivation)': 'ปุ๋ยฟอสฟอรัส (การเพาะปลูกสับปะรด)',
  'Phosphorus (nutrient)': 'ฟอสฟอรัส (ธาตุอาหาร)',
  'Pineapple core output (2020 national estimate)': 'ผลผลิตแกนสับปะรด (ประมาณการระดับประเทศ ปี 2020)',
  'Pineapple feedstock input (2020 national estimate)': 'วัตถุดิบสับปะรดขาเข้า (ประมาณการระดับประเทศ ปี 2020)',
  'Pineapple peel output (2020 national estimate)': 'ผลผลิตเปลือกสับปะรด (ประมาณการระดับประเทศ ปี 2020)',
  'Pineapple processing residues output (stems and crowns)': 'ผลผลิตเศษเหลือสับปะรด (ลำต้นและจุก)',
  'Potassium fertilizer (pineapple cultivation)': 'ปุ๋ยโพแทสเซียม (การเพาะปลูกสับปะรด)',
  'Potassium (nutrient)': 'โพแทสเซียม (ธาตุอาหาร)',
  'Processing chemical (unspecified)': 'สารเคมีสำหรับแปรรูป (ไม่ระบุชนิด)',
  Rainwater: 'น้ำฝน', 'Rhizome (dry basis)': 'เหง้า (น้ำหนักแห้ง)',
  'Rice bran': productNames['Rice bran'], 'Rice husk': productNames['Rice husk'], 'Rice seed': 'เมล็ดพันธุ์ข้าว',
  'Sand and soil (dry basis)': 'ทรายและดิน (น้ำหนักแห้ง)',
  'Sugarcane tops and leaves': 'ยอดและใบอ้อย',
  'Sugar (pineapple processing)': 'น้ำตาล (การแปรรูปสับปะรด)',
  'Tin can (pineapple processing)': 'กระป๋องดีบุก (การแปรรูปสับปะรด)',
  'Urea (46-0-0)': 'ยูเรีย (46-0-0)',
  'Wastewater to final open lagoons': 'น้ำเสียเข้าสู่บ่อบำบัดแบบเปิดขั้นสุดท้าย',
  'Water use (reported aggregate)': 'ปริมาณการใช้น้ำ (ค่ารวมตามรายงาน)',
  'Water use (sugar production)': 'ปริมาณการใช้น้ำ (การผลิตน้ำตาล)',
  'Withered rice': productNames['Withered rice'],
};

const stepDescriptions: Record<string, string> = {
  'Aggregated milling yield (Table 14B)': 'รายงานผลได้รวมจากการสี ไม่ได้แจกแจงปริมาณแยกตามขั้นตอน',
  'Aggregated starch production': 'ข้อมูลรวมจากตารางที่ 1 ปรับฐานเป็นแป้ง 1,000 กก. ที่ความชื้น 0%',
  'Canning and packaging (one 30 oz. can)': 'ข้อมูลการผลิตและบรรจุสับปะรดกระป๋อง 1 กระป๋อง ขนาด 30 ออนซ์',
  'Cassava field cultivation': 'ข้อมูลการเพาะปลูกมันสำปะหลังจากแหล่งอ้างอิง',
  'Cleaning and pre-treatment': 'ขั้นตอนทำความสะอาดและเตรียมวัตถุดิบก่อนแปรรูป',
  'Cultivation and harvesting': 'รวมปัจจัยการเพาะปลูกและเก็บเกี่ยวต่อพื้นที่ 1 เฮกตาร์',
  'Cultivation (whole crop-cycle inventory)': 'รวมข้อมูลตลอดรอบการเพาะปลูก ไม่ได้แจกแจงปัจจัยตามขั้นตอนย่อย',
  'Farming': 'ข้อมูลการผลิตทางการเกษตรจากแหล่งอ้างอิง',
  'Field preparation': 'เตรียมแปลงสำหรับการเพาะปลูก',
  'Harvesting': 'เก็บเกี่ยวผลผลิต',
  'Harvesting and cleaning': 'เก็บเกี่ยวและทำความสะอาดผลผลิต',
  'Harvesting and milling': 'เก็บเกี่ยวและหีบอ้อยเพื่อแยกผลผลิต',
  'Husking': 'กะเทาะเปลือกเพื่อแยกแกลบออกจากเมล็ดข้าว',
  'Land preparation': 'เตรียมพื้นที่ก่อนเริ่มเพาะปลูก',
  'Planting': 'ปลูกพืชตามข้อมูลที่รายงาน',
  'Post harvesting (open burning)': 'การจัดการหลังเก็บเกี่ยวโดยการเผาในที่โล่ง',
  'Separation of pineapple processing by-products': 'แยกและประมาณปริมาณผลพลอยได้จากการแปรรูปสับปะรด',
  'Small-machine milling at 12.1% paddy moisture': 'ทดลองสีข้าวเปลือก 10 กก. ด้วยเครื่องขนาดเล็กที่ความชื้น 12.1%',
  'Soil preparation': 'เตรียมดินตามข้อมูลการเพาะปลูก',
  'Sugarcane cultivation (1 hectare)': 'ข้อมูลการเพาะปลูกอ้อยต่อพื้นที่ 1 เฮกตาร์',
  'Sugarcane milling and co-product generation': 'แยกน้ำตาลและผลผลิตร่วมจากอ้อยที่เข้าโรงงาน',
  'Sugar production (per 1 kg sugar)': 'ข้อมูลการผลิตน้ำตาลต่อผลิตภัณฑ์น้ำตาล 1 กก.',
  'Transportation of 58 tonnes of sugarcane': 'ขนส่งอ้อย 58 ตันไปยังโรงงาน',
  'Weeding': 'กำจัดวัชพืชในแปลงเพาะปลูก',
  'Whitening': 'ขัดข้าวกล้องให้เป็นข้าวขาว',
  'Whole-system LCI - ecoinvent v3.0 (functional unit: 1 kg maize grain)': 'รวมบัญชีวัฏจักรชีวิตตามฐาน ecoinvent v3.0 ต่อเมล็ดข้าวโพด 1 กก.',
  'Whole-system LCI - IDEA v2.0 (functional unit: 1 kg maize grain)': 'รวมบัญชีวัฏจักรชีวิตตามฐาน IDEA v2.0 ต่อเมล็ดข้าวโพด 1 กก.',
};

export function localizeProductName(value: string): string {
  return productNames[value] || value;
}

export function localizeProductDescription(value: string | null): string {
  if (!value) return '';
  return descriptions[value] || value;
}

export function localizeCategory(value: string): string {
  return categories[value] || value;
}

export function categoryColor(value: string): string {
  const palette: Record<string, string> = {
    'National rice statistics': '#FFE59A',
    'Organic rice': '#B7E1D1',
    'Milled rice and rice by-products': '#FFE59A',
    'Rice milling reference': '#A9D3FF',
    'Cassava and tapioca starch products': '#E8C9F2',
    'Maize and maize residues': '#F3D77A',
    'Sugarcane and sugar products': '#CFE4AC',
    'Pineapple and pineapple products': '#FFC895',
  };
  return palette[value] || '#B7E1D1';
}

export function localizeLocation(value: string | null): string {
  if (!value) return '';
  return locations[value] || value;
}

export function localizeFunctionalUnit(value: string): string {
  return value
    .replace(/^1 can \(30 oz\)$/i, '1 กระป๋อง (30 ออนซ์)')
    .replace(/\bt\b/gi, 'ตัน')
    .replace(/\bkg dry\b/gi, 'กก. น้ำหนักแห้ง')
    .replace(/\bkg\b/gi, 'กก.');
}

export function localizeCategoryLabel(value: string): string {
  if (value === 'All') return 'ทั้งหมด';
  return localizeCategory(value);
}

export function localizeFlowName(value: string): string {
  if (exactFlowNames[value]) return exactFlowNames[value];
  return value
    .replace('Carbon dioxide', 'คาร์บอนไดออกไซด์')
    .replace('Carbon monoxide', 'คาร์บอนมอนอกไซด์')
    .replace('Nitrous oxide', 'ไนตรัสออกไซด์')
    .replace('Methane', 'มีเทน')
    .replace('Sulfur dioxide', 'ซัลเฟอร์ไดออกไซด์')
    .replace('Hydrogen chloride', 'ไฮโดรเจนคลอไรด์')
    .replace('Biochemical oxygen demand', 'ความต้องการออกซิเจนทางชีวเคมี')
    .replace('Chemical oxygen demand', 'ความต้องการออกซิเจนทางเคมี')
    .replace('Non-methane volatile organic compounds', 'สารอินทรีย์ระเหยง่ายที่ไม่มีมีเทน')
    .replace('CO2', 'CO₂')
    .replace('NOx', 'ออกไซด์ของไนโตรเจน')
    .replace('SO2', 'ซัลเฟอร์ไดออกไซด์')
    .replace('PM2.5', 'ฝุ่นละออง PM2.5')
    .replace('Natural gas', 'ก๊าซธรรมชาติ')
    .replace('Coal', 'ถ่านหิน')
    .replace('Electricity', 'ไฟฟ้า')
    .replace('electricity', 'ไฟฟ้า')
    .replace('Gasoline', 'น้ำมันเบนซิน')
    .replace('Oil', 'น้ำมัน')
    .replace('herbicide', 'สารกำจัดวัชพืช')
    .replace('Herbicide', 'สารกำจัดวัชพืช')
    .replace('insecticide', 'สารกำจัดแมลง')
    .replace('Insecticide', 'สารกำจัดแมลง')
    .replace('Total suspended particulates', 'ฝุ่นแขวนลอยทั้งหมด')
    .replace('Suspended solids', 'ของแข็งแขวนลอย')
    .replace('Total dissolved solids', 'ของแข็งละลายทั้งหมด')
    .replace('Wastewater', 'น้ำเสีย')
    .replace('Water', 'น้ำ')
    .replace('Fertilizer', 'ปุ๋ย')
    .replace('fertilizer', 'ปุ๋ย')
    .replace('Sugarcane', 'อ้อย')
    .replace('sugarcane', 'อ้อย')
    .replace('Pineapple', 'สับปะรด')
    .replace('pineapple', 'สับปะรด')
    .replace('Cassava', 'มันสำปะหลัง')
    .replace('cassava', 'มันสำปะหลัง')
    .replace('Maize', 'ข้าวโพด')
    .replace('maize', 'ข้าวโพด')
    .replace('Rice', 'ข้าว')
    .replace('rice', 'ข้าว')
    .replace('Sugar', 'น้ำตาล')
    .replace('sugar', 'น้ำตาล')
    .replace('cultivation', 'การเพาะปลูก')
    .replace('processing', 'การแปรรูป')
    .replace('output', 'ผลผลิต')
    .replace('input', 'วัตถุดิบที่นำเข้า')
    .replace('Carbon', 'คาร์บอน');
}

export function localizeImpactType(value: string): string {
  const labels: Record<string, string> = {
    'global warming': 'ภาวะโลกร้อน',
    'freshwater eutrophication': 'ภาวะสารอาหารเกินในแหล่งน้ำจืด',
    'terrestrial acidification': 'การเกิดกรดในระบบนิเวศบนบก',
    'freshwater ecotoxicity': 'ความเป็นพิษต่อระบบนิเวศน้ำจืด',
    'terrestrial ecotoxicity': 'ความเป็นพิษต่อระบบนิเวศบนบก',
    'reported total ghg emissions (gate-to-gate, scenario 1)': 'การปล่อยก๊าซเรือนกระจกรวมตามรายงาน (เฉพาะโรงงาน, กรณีที่ 1)',
  };
  return labels[value.toLowerCase()] || value;
}

export function localizeUnit(value: string): string {
  const labels: Record<string, string> = {
    kg: 'กก.', L: 'ลิตร', m3: 'ลบ.ม.', kWh: 'กิโลวัตต์ชั่วโมง', t: 'ตัน',
    'kg CO2-eq': 'กก. คาร์บอนไดออกไซด์เทียบเท่า',
    'kg SO2-eq': 'กก. ซัลเฟอร์ไดออกไซด์เทียบเท่า',
    'kg PO4-eq': 'กก. ฟอสเฟตเทียบเท่า', 'kg 1,4-DCB': 'กก. 1,4-ไดคลอโรเบนซีน',
    m2: 'ตร.ม.', m2y: 'ตร.ม.-ปี', 'can (30 oz)': 'กระป๋อง (30 ออนซ์)',
    'kg dry': 'กก. น้ำหนักแห้ง',
  };
  return labels[value] || value;
}

export function localizeUnitId(value: number): string {
  const units: Record<number, string> = {
    1: 'กก.', 2: 'ลิตร', 3: 'ลบ.ม.', 4: 'กิโลวัตต์ชั่วโมง',
    5: 'กก. CO₂e', 6: 'กก. SO₂e', 7: 'กก. PO₄e', 8: 'กก. 1,4-DCB',
    9: 'กก. น้ำหนักแห้ง', 10: 'ตร.ม.', 11: 'ตร.ม.-ปี', 12: 'กระป๋อง (30 ออนซ์)',
  };
  return units[value] || `หน่วย ${value}`;
}

export function localizeProcessStep(name: string, description: string | null) {
  return {
    name: processSteps[name] || name,
    description: stepDescriptions[name] || description || '',
  };
}

export function localizeSupplier(value: string): string {
  if (/not specified in source data/i.test(value)) return 'ไม่ได้ระบุในแหล่งข้อมูล';
  if (/not specified/i.test(value)) return 'ไม่ได้ระบุ';
  return value;
}

export function iconForCategory(category: string): 'rice' | 'cassava' | 'maize' | 'sugar' | 'pineapple' {
  if (category.includes('Cassava')) return 'cassava';
  if (category.includes('Maize')) return 'maize';
  if (category.includes('Sugarcane')) return 'sugar';
  if (category.includes('Pineapple')) return 'pineapple';
  return 'rice';
}

export function emojiForCategory(category: string): string {
  const emoji: Record<ReturnType<typeof iconForCategory>, string> = {
    rice: '🌾',
    cassava: '🥔',
    maize: '🌽',
    sugar: '🎋',
    pineapple: '🍍',
  };
  return emoji[iconForCategory(category)];
}

export function getProductAccent(product: ProductRecord): string {
  return categoryColor(product.category);
}
