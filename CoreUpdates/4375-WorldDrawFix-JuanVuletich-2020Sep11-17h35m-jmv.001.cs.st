'From Cuis 5.0 [latest update: #4373] on 11 September 2020 at 5:39:28 pm'!

!MorphicCanvas methodsFor: 'morphic world' stamp: 'jmv 9/11/2020 17:38:48'!
computeDamage: aPasteUpMorph repair: aDamageRecorder rootMorphs: rootMorphs rootMorphsDamage: rootMorphsDamage
	"Iterate front to back while computing damage to actually repair for each morph, and for world background.
	Answer uncoveredDamage, the areas where World background needs to be redrawn."

	| uncoveredDamage morph morphDamage prevMorphDamage reuseInstance morphBefore |
	morphDamage _ OrderedCollection new.
	prevMorphDamage _ OrderedCollection new.
	uncoveredDamage _ aDamageRecorder damageReportedOther.
	"Iterate from front to back"
	1 to: rootMorphs size do: [ :i |
		morph _ rootMorphs at: i.
		morphDamage removeAll.
		(aDamageRecorder damageReportedFor: morph) ifNotNil: [ :r |
			morphDamage add: r ].
		1 to: i-1 do: [ :j |
			reuseInstance _ prevMorphDamage.
			prevMorphDamage _ morphDamage.
			morphDamage _ reuseInstance removeAll.
			morphBefore _ rootMorphs at: j.
			prevMorphDamage do: [ :r |
				morphBefore addPossiblyUncoveredAreasIn: r to: morphDamage ]].
		(Rectangle merging: morphDamage) ifNotNil: [ :morphDamageRect |
			rootMorphsDamage at: i put: morphDamageRect.
			morph addPossiblyUncoveredAreasIn: morphDamageRect to: uncoveredDamage ]].

	^ uncoveredDamage! !

!MorphicCanvas methodsFor: 'morphic world' stamp: 'jmv 9/11/2020 17:37:15'!
drawWorld: aPasteUpMorph rootMorphs: rootMorphs rootMorphsDamage: rootMorphsDamage allDamage: worldDamage
	"Redraw the damaged areas.
	Draw each morph just once, merging rectanges to be repaired as needed."

	| morph morphDamage |

	"Iterate from back to front."
	rootMorphs size to: 1 by: -1 do: [ :i |
		morph _ rootMorphs at: i.
		morph visible ifTrue: [
			morphDamage _ rootMorphsDamage at: i.
			morph displayFullBounds ifNotNil: [ :morphFullBounds |
				worldDamage do: [ :r | | intersection |
					intersection _ r intersect: morphFullBounds.
					intersection hasPositiveExtent ifTrue: [
						morphDamage _ intersection quickMerge: morphDamage ]]].
			morphDamage ifNotNil: [
				self newClipRect: morphDamage.
				self fullDraw: morph.
				worldDamage add: morphDamage ]]].! !

